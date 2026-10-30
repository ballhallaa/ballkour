#!/usr/bin/env python3
"""Link each course to the shared translations, and build test previews of them.

  python3 tools/translations.py                    link the courses, show progress
  python3 tools/translations.py preview [course]   write test builds to previews/

OverPy reads and rewrites the translations of a course at
src/courses/<course>/<course>.<language>.po, for each language in the #!translations
directive (src/ballkour.opy). All the translated text is in the engine, so every course
shares src/translations/<language>.po, and the course's .po file is a symlink to it. Run
this after adding a course or a language: it makes the missing links, then lists what is
left to translate.

To translate, edit src/translations/<language>.po (with a .po editor such as Poedit, or
by hand), then recompile a course (OverPy: Compile). Keep the {0}-style placeholders and
<fg> tags. Workshop text has no columns or centering, so the controls HUD and the run
completion text line up with spaces: pad a translation until it lines up in-game.
OverPy adds a line's leading and trailing spaces back to every language, so those lines
start with a color tag to keep their padding part of the translation.

Previews check a translation in-game without changing Overwatch's language. preview
writes previews/<language>.opy for each language (the course in that language, whatever
the game's language) and previews/language-check.opy (the real language detection, with
the map name it reads at the top of the screen). Compile one (OverPy: Compile) and paste
it. Every controls line shows at once, and Interact cycles the run completion screens.
Previews read the .po files directly, so after editing one just recompile the preview.
They're test builds: don't publish them. The course defaults to the first one.

Changing Overwatch's language is the Language setting in Steam (or Battle.net), as the
--tank_Locale launch option leaves the names the Workshop reads in English.
"""

import argparse
import os
import re
import sys

from overpy import SRC, courses, find_course

TRANSLATIONS = SRC / "translations"
PREVIEWS = SRC.parent / "previews"
LANGUAGES_RE = re.compile(r"^#!translations (.+)$", re.M)
# An entry is its comments, msgid, then msgstr, each string continued on the lines after
ENTRY_RE = re.compile(r'^msgid ((?:".*"\n)+)msgstr ((?:".*"\n?)+)', re.M)

# Post-compile hooks get the compiled Workshop text as content, and output their last value.
# This one makes the HUD texts whose visibility checks isViewingCtrlsHud visible to everyone.
SHOW_CONTROLS_JS = """\
function showControls(text) {
    const start = "Create HUD Text(";
    let out = "", i = 0, j;
    while ((j = text.indexOf(start, i)) !== -1) {
        const from = j + start.length;
        let depth = 0, k = from;
        for (; ; k++) {
            if (text[k] === "(") depth++;
            else if (text[k] === ")") depth--;
            else if (text[k] === "," && depth === 0) break;
        }
        const visibleTo = text.slice(from, k);
        const controls = visibleTo.includes(".isViewingCtrlsHud");
        out += text.slice(i, from) + (controls ? "All Players(All Teams)" : visibleTo);
        i = k;
    }
    return out + text.slice(i);
}
"""
# Swaps each language detection for 2, the preview's language (#!translations en <language>)
FORCE_LANGUAGE_JS = """\
function forceLanguage(text) {
    const start = "Absolute Value(Index Of Array Value(Global.__overpyTranslationHelper__,";
    let out = "", i = 0, j;
    while ((j = text.indexOf(start, i)) !== -1) {
        let depth = 0, k = j;
        for (; ; k++) {
            if (text[k] === "(") depth++;
            else if (text[k] === ")" && --depth === 0) break;
        }
        out += text.slice(i, j) + "2";
        i = k + 1;
    }
    return out + text.slice(i);
}
"""
PREVIEW_RULES = """\
# Interact cycles the run completion screens: slower than the time to beat, a top-10
# time, a run that doesn't count, then hidden. It stops the run timer to set the run
# time, so use it in the lobby.

playervar previewCompletion


rule "Preview: Cycle Run Completion Text":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false

    eventPlayer.previewCompletion = (eventPlayer.previewCompletion + 1) % 4
    stopChasingVariable(eventPlayer.runTime)
    eventPlayer.runTime = 999999 if eventPlayer.previewCompletion == 1 else 0
    eventPlayer.isRunLegit = eventPlayer.previewCompletion != 3
    # Turned off first, so Load Run Text restarts its 30 seconds
    eventPlayer.isViewingRunCompletionText = false
    wait()
    eventPlayer.isViewingRunCompletionText = eventPlayer.previewCompletion > 0
"""
LANGUAGE_CHECK_RULE = """

rule "Preview: Language Check HUD":
    hudSubheader(
        getAllPlayers(),
        "Language check: {}".format(updateEveryFrame(Map.ILIOS_RUINS)),
        HudPosition.TOP,
        -1,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING
    )
"""


def languages():
    if not (m := LANGUAGES_RE.search((SRC / "ballkour.opy").read_text())):
        sys.exit("src/ballkour.opy has no #!translations directive")
    # The first language is the one the source is written in
    return m[1].split()[1:]


def link(course, language):
    """Points the course's .po file for the language at the shared one."""
    path = course.with_name(f"{course.stem}.{language}.po")
    target = TRANSLATIONS / f"{language}.po"
    if path.is_symlink() and path.resolve() == target.resolve():
        return
    if path.exists() and not path.is_symlink() and not target.exists():
        # A course compiled before the language had a shared file
        path.rename(target)
    else:
        path.unlink(missing_ok=True)
    if not target.exists():
        target.touch()
    path.symlink_to(os.path.relpath(target, path.parent))
    print(f"linked {path.relative_to(SRC.parent)} -> {target.relative_to(SRC.parent)}")


def progress(language):
    """Returns how many of the language's strings are translated, and how many there are."""
    entries = ENTRY_RE.findall((TRANSLATIONS / f"{language}.po").read_text())[1:]
    # An empty msgstr is one line, and OverPy shows the source string instead
    return sum(msgstr.strip() != '""' for _, msgstr in entries), len(entries)


def status(args):
    TRANSLATIONS.mkdir(exist_ok=True)
    for course in courses():
        for language in languages():
            link(course, language)
    for language in languages():
        translated, total = progress(language)
        print(f"{language}: {translated}/{total} translated")
    print("Recompile a course to add new strings to the .po files.")


def write_preview(name, course, comment, language, hook, extra=""):
    """Writes previews/<name>.opy, shown in the language, or detected if it's None."""
    (PREVIEWS / f"{name}.opy").write_text(
        f"# {comment} Test build: don't publish it.\n"
        f'#!include "../src/{course.relative_to(SRC)}"\n'
        '#!include "preview-rules.opy"\n'
        + (f"#!translations en {language}\n" if language else "")
        + f'#!postCompileHook "{hook}"\n'
        + extra
    )
    # OverPy looks for a main file's translations next to it, named after it
    for language in [language] if language else languages():
        (PREVIEWS / f"{name}.{language}.po").symlink_to(
            f"../src/translations/{language}.po"
        )


def preview(args):
    course = find_course(args.course) if args.course else courses()[0]
    PREVIEWS.mkdir(exist_ok=True)
    for path in PREVIEWS.iterdir():
        path.unlink()
    (PREVIEWS / "show-controls.js").write_text(
        SHOW_CONTROLS_JS + "\nshowControls(content).toString();\n"
    )
    (PREVIEWS / "force-language.js").write_text(
        SHOW_CONTROLS_JS
        + "\n"
        + FORCE_LANGUAGE_JS
        + "\nforceLanguage(showControls(content)).toString();\n"
    )
    (PREVIEWS / "preview-rules.opy").write_text(PREVIEW_RULES)
    for language in languages():
        write_preview(
            language,
            course,
            f"{course.stem} in {language}, whatever the game's language.",
            language,
            "force-language.js",
        )
    write_preview(
        "language-check",
        course,
        f"{course.stem} with the real language detection, and the map name it reads.",
        None,
        "show-controls.js",
        LANGUAGE_CHECK_RULE,
    )
    print(
        f"Wrote {course.stem} previews for {' '.join(languages())} and language-check"
        f" to {PREVIEWS.relative_to(SRC.parent)}/"
    )


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.set_defaults(run=status)
    commands = parser.add_subparsers()
    preview_parser = commands.add_parser(
        "preview", help="write test builds that show a translation in-game"
    )
    preview_parser.add_argument(
        "course", nargs="?", help="course file or part of its name (default: the first)"
    )
    preview_parser.set_defaults(run=preview)
    args = parser.parse_args()
    args.run(args)


if __name__ == "__main__":
    main()

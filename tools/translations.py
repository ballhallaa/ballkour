#!/usr/bin/env python3
"""Link each course to the shared translations.

  python3 tools/translations.py    link the courses, show progress

OverPy reads and rewrites the translations of a course at
src/courses/<course>/<course>.<language>.po, for each language in the #!translations
directive (src/ballkour.opy). All the translated text is in the engine, so every course
shares src/translations/<language>.po, and the course's .po file is a symlink to it. Run
this after adding a course or a language: it makes the missing links, then lists what is
left to translate. Run it after changing an English line's spacing too: the English is how
each .po file finds its translation, so the translations would otherwise come back empty.
It carries them over to the new spacing, and if a compile already emptied them, it takes
them back from the last commit. It also puts each rule's lines in the order the source has
them, as OverPy adds a line it hasn't seen after the rest.

To translate, edit src/translations/<language>.po (with a .po editor such as Poedit, or
by hand), then recompile a course (OverPy: Compile). Keep the {0}-style placeholders and
<fg> tags. Workshop text has no columns or centering, so the controls HUD and the run
completion text line up with spaces: pad a translation until it lines up in-game.
OverPy adds a line's leading and trailing spaces back to every language, so those lines
start with a color tag to keep their padding part of the translation.

To check a translation in-game, switch to it with Ultimate + Jump + Primary/Secondary
Fire (Prev./Next Language), or from the list in the lobby.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from overpy import SRC, compile_files, courses

TRANSLATIONS = SRC / "translations"
LANGUAGES_RE = re.compile(r"^#!translations (.+)$", re.M)
# An entry is its comments, msgid, then msgstr, each string continued on the lines after
ENTRY_RE = re.compile(r'^msgid ((?:".*"\n)+)msgstr ((?:".*"\n?)+)', re.M)
# A translated string in the source: _( and its string literals, joined up
SOURCE_RE = re.compile(r'\b_\(\s*((?:"(?:[^"\\\n]|\\.)*"\s*)+)\)')
LITERAL_RE = re.compile(r'"((?:[^"\\\n]|\\.)*)"')
FILE_RE = re.compile(r"file (\S+), rule")


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


def spacing_key(msgid):
    """A msgid without its spaces, so a respaced English line still matches its old one."""
    return re.sub(r'[\s"]', "", msgid)


def follow_respacing():
    """Moves translations over to English lines whose spaces changed in the source.

    OverPy writes a course's .po files when it compiles, so a copy of src/ compiles into a
    temporary folder, and its .po files list the English as it is now. Each line in them that
    the real .po files don't have takes the translation of the one line there that it matches
    apart from spaces, and isn't in the source any more.
    """
    with tempfile.TemporaryDirectory() as tmp:
        copy = Path(tmp)
        shutil.copytree(SRC, copy / "src", symlinks=True)
        shutil.copytree(SRC.parent / "leaderboards", copy / "leaderboards")
        results = compile_files(courses(copy / "src")[:1])
        if results is None:
            print("Skipped respacing: needs node and the OverPy VS Code extension")
            return
        if "error" in results[0]:
            sys.exit(f"OverPy compile failed: {results[0]['error']}")
        for language in languages():
            path = TRANSLATIONS / f"{language}.po"
            text = path.read_text()
            old = [m[1] for m in ENTRY_RE.finditer(text)][1:]
            new = [
                m[1]
                for m in ENTRY_RE.finditer(
                    (copy / "src" / "translations" / f"{language}.po").read_text()
                )
            ][1:]
            gone = [msgid for msgid in old if msgid not in new]
            moved = 0
            for msgid in new:
                if msgid in old:
                    continue
                matches = [g for g in gone if spacing_key(g) == spacing_key(msgid)]
                if len(matches) == 1:
                    text = text.replace(f"msgid {matches[0]}", f"msgid {msgid}", 1)
                    gone.remove(matches[0])
                    moved += 1
            if moved:
                path.write_text(text)
                print(
                    f"{language}: kept {moved} translation(s) through a spacing change"
                )


def recover_from_commit():
    """Refills translations a compile emptied after their English was respaced.

    Compiling before running this drops the old line, so its translation comes back from the
    last commit's .po file instead, by the same match apart from spaces.
    """
    for language in languages():
        path = TRANSLATIONS / f"{language}.po"
        committed = subprocess.run(
            ["git", "show", f"HEAD:src/translations/{language}.po"],
            cwd=SRC.parent,
            capture_output=True,
            text=True,
        )
        if committed.returncode:
            continue
        before = {}
        for m in ENTRY_RE.finditer(committed.stdout):
            if m[2].strip() != '""':
                before.setdefault(spacing_key(m[1]), []).append(m[2])
        text = path.read_text()
        recovered = 0
        for m in ENTRY_RE.finditer(text):
            found = before.get(spacing_key(m[1]), [])
            if m[2].strip() == '""' and len(found) == 1:
                text = text.replace(m[0], f"msgid {m[1]}msgstr {found[0]}", 1)
                recovered += 1
        if recovered:
            path.write_text(text)
            print(
                f"{language}: took {recovered} emptied translation(s) from the last commit"
            )


def source_order():
    """Each translated string's place in its source file, by file name and spacing_key."""
    order = {}
    for path in SRC.rglob("*.opy"):
        places = order.setdefault(path.name, {})
        for m in SOURCE_RE.finditer(path.read_text()):
            text = "".join(LITERAL_RE.findall(m[1]))
            # OverPy numbers the {}s in a msgid
            count = iter(range(text.count("{}")))
            text = re.sub(r"\{\}", lambda _: "{%d}" % next(count), text)
            places.setdefault(spacing_key(text), len(places))
    return order


def sort_entries():
    """Puts the lines under each rule in the order of its source file.

    OverPy sorts entries by their comments (file and rule), keeping the order the file
    already had among entries that share them, so this only reorders runs of entries with
    the same comments, and OverPy keeps it.
    """
    order = source_order()
    for language in languages():
        path = TRANSLATIONS / f"{language}.po"
        header, *blocks = path.read_text().rstrip("\n").split("\n\n")
        comments = [b[: b.index("msgid ")] if "msgid " in b else b for b in blocks]

        def place(i):
            file = FILE_RE.search(comments[i])
            msgid = ENTRY_RE.search(blocks[i] + "\n")
            places = order.get(file[1], {}) if file else {}
            return places.get(spacing_key(msgid[1]) if msgid else "", len(places))

        result, i = [], 0
        while i < len(blocks):
            j = i
            while j < len(blocks) and comments[j] == comments[i]:
                j += 1
            result += [
                blocks[k] for k in sorted(range(i, j), key=lambda k: (place(k), k))
            ]
            i = j
        text = "\n\n".join([header] + result) + "\n"
        if text != path.read_text():
            path.write_text(text)
            print(f"{language}: put lines in source order")


def progress(language):
    """Returns how many of the language's strings are translated, and how many there are."""
    entries = ENTRY_RE.findall((TRANSLATIONS / f"{language}.po").read_text())[1:]
    # An empty msgstr is one line, and OverPy shows the source string instead
    return sum(msgstr.strip() != '""' for _, msgstr in entries), len(entries)


def status():
    TRANSLATIONS.mkdir(exist_ok=True)
    for course in courses():
        for language in languages():
            link(course, language)
    follow_respacing()
    recover_from_commit()
    sort_entries()
    for language in languages():
        translated, total = progress(language)
        print(f"{language}: {translated}/{total} translated")
    print("Recompile a course to add new strings to the .po files.")


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.parse_args()
    status()


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Check or fix black formatting in the OverPy sources.

  python3 tools/format.py            show what black would change
  python3 tools/format.py --fix      apply it
  python3 tools/format.py file...    only check these files

Black only reads Python, so OverPy-only lines (rule headers, annotations like
@Condition, globalvar/playervar/subroutine, macros, x++) are swapped for Python of the
same width, formatted, then swapped back. The trailing commas black adds are taken out
again, since OverPy rejects them after a function's last argument. Strings split one
per line (like a HUD text with a line per row) get a comment while black runs, since
black otherwise joins them back onto one line whenever they fit.

By default this checks src/ except the generated hint files (src/hints/, see
tools/hints.py) and the courses, whose settings and cps tables are laid out by hand.

Needs black on the PATH (sudo pacman -S python-black, or pipx install black). Written
against black 26.10.1: black's style changes a little each year. --fix also needs node
and the OverPy VS Code extension, because it compiles every course before and after and
only writes the changes if the compiled output is the same.
"""

import argparse
import difflib
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from overpy import SRC, compile_files, courses

RULE_RE = re.compile(r"^rule\b")
ANNOTATION_RE = re.compile(r"^(\s*)@(\w+) (.*)$")
DECLARATION_RE = re.compile(r"^(globalvar|playervar|subroutine)\b")
MACRO_RE = re.compile(r"^macro (\w+)(\(?)")
INCREMENT_RE = re.compile(r"^(\s*\S.*?)(\+\+|--)$")
# Python stand-ins for those lines, the same width wherever black could wrap them
RULE_STANDIN_RE = re.compile(r"^def _rule_(\d+)\(\):$")
DECLARATION_STANDIN = "#!_"
MACRO_STANDIN = "_MACR_"
INCREMENT_STANDIN_RE = re.compile(r"^(.*?) [+-]= 1  # _(\+\+|--)$")
STRING_LINE_RE = re.compile(r'^\s*"(?:[^"\\]|\\.)*"$')
SPLIT_STRING_MARKER = "  # _split"
CLOSING_RE = re.compile(r"^\s*[)\]}]")
TRAILING_COMMA_RE = re.compile(r",(\s*#.*)?$")


def to_python(source):
    """Returns the source with OverPy-only lines swapped out, and what was swapped."""
    lines, rules, annotations = [], [], {}
    for line in source.split("\n"):
        if RULE_RE.match(line):
            lines.append(f"def _rule_{len(rules)}():")
            rules.append(line)
        elif m := ANNOTATION_RE.match(line):
            # "@Condition " and "_Conditi = " are the same width
            alias = "_" + m[2][:-2]
            annotations[alias] = m[2]
            lines.append(f"{m[1]}{alias} = {m[3]}")
        elif DECLARATION_RE.match(line):
            lines.append(DECLARATION_STANDIN + line)
        elif m := MACRO_RE.match(line):
            standin = ("def " if m[2] else "") + MACRO_STANDIN
            lines.append(standin + line[len("macro ") :])
        elif m := INCREMENT_RE.match(line):
            lines.append(f"{m[1]} {m[2][0]}= 1  # _{m[2]}")
        else:
            lines.append(line)
    # Black can't join a line that ends in a comment onto the next one
    is_string = [bool(STRING_LINE_RE.match(line)) for line in lines]
    for i, line in enumerate(lines):
        if is_string[i] and (
            (i > 0 and is_string[i - 1]) or (i + 1 < len(lines) and is_string[i + 1])
        ):
            lines[i] = line + SPLIT_STRING_MARKER
    return "\n".join(lines), (rules, annotations)


def from_python(python, swapped):
    rules, annotations = swapped
    lines = python.split("\n")
    for i, line in enumerate(lines):
        if m := RULE_STANDIN_RE.match(line):
            line = rules[int(m[1])]
        elif (m := re.match(r"^(\s*)(_\w+) = (.*)$", line)) and m[2] in annotations:
            line = f"{m[1]}@{annotations[m[2]]} {m[3]}"
        elif line.startswith(DECLARATION_STANDIN):
            line = line[len(DECLARATION_STANDIN) :]
        elif m := INCREMENT_STANDIN_RE.match(line):
            line = m[1] + m[2]
        else:
            line = re.sub(rf"^(def )?{MACRO_STANDIN}", "macro ", line)
        line = line.removesuffix(SPLIT_STRING_MARKER)
        if i + 1 < len(lines) and CLOSING_RE.match(lines[i + 1]):
            line = TRAILING_COMMA_RE.sub(r"\1", line)
        lines[i] = line
    return "\n".join(lines)


def run_black(sources):
    """Formats each source, returning the results and black's error for each, if any."""
    black = shutil.which("black")
    if not black:
        sys.exit(
            "black isn't installed: sudo pacman -S python-black, or pipx install black"
        )
    with tempfile.TemporaryDirectory() as tmp:
        files = [Path(tmp, f"{i}.py") for i in range(len(sources))]
        for file, source in zip(files, sources):
            file.write_text(source)
        result = subprocess.run(
            [black, "--quiet", "--skip-magic-trailing-comma", *map(str, files)],
            capture_output=True,
            text=True,
            # Keeps black from caching the throwaway files
            env={**os.environ, "BLACK_CACHE_DIR": tmp},
        )
        errors = [None] * len(sources)
        for m in re.finditer(r"cannot format .*?(\d+)\.py: (.*)", result.stderr):
            errors[int(m[1])] = m[2]
        if result.returncode and not any(errors):
            sys.exit(f"black failed: {result.stderr.strip()}")
        return [file.read_text() for file in files], errors


def check_compiled_output(changed):
    """Exits unless every course compiles exactly the same with the changed files."""
    names = [course.name for course in courses()]
    with tempfile.TemporaryDirectory() as tmp:
        before, after = Path(tmp, "before"), Path(tmp, "after")
        for copy in (before, after):
            shutil.copytree(SRC, copy)
            # Dev builds leave nothing out, so the dev-only code is checked too
            version = copy / "VERSION"
            version.write_text(
                re.sub(r'"([^"]*?)(-dev)?"', r'"\1-dev"', version.read_text())
            )
        for file, text in changed.items():
            (after / file.relative_to(SRC)).write_text(text)
        results = compile_files(
            [before / n for n in names] + [after / n for n in names]
        )
    if results is None:
        sys.exit(
            "--fix needs node and the OverPy VS Code extension, to check that the"
            " compiled output doesn't change"
        )
    for name, old, new in zip(names, results, results[len(names) :]):
        if "error" in old:
            sys.exit(f"{name} doesn't compile even before formatting: {old['error']}")
        if "error" in new:
            sys.exit(
                f"Nothing changed: {name} doesn't compile after formatting: {new['error']}"
            )
        if new["result"] != old["result"]:
            diff = difflib.unified_diff(
                old["result"].split("\n"),
                new["result"].split("\n"),
                "before",
                "after",
                n=1,
                lineterm="",
            )
            sys.exit(
                f"Nothing changed: {name} compiles differently after formatting:\n"
                + "\n".join(list(diff)[:40])
            )


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("files", nargs="*", type=Path, metavar="file")
    parser.add_argument("--fix", action="store_true", help="apply black's changes")
    args = parser.parse_args()

    skipped = set(courses()) | set(SRC.glob("hints/*.opy"))
    files = [f.resolve() for f in args.files] or [
        p for p in sorted(SRC.rglob("*.opy")) if p not in skipped
    ]
    sources = [file.read_text() for file in files]
    translated = [to_python(source) for source in sources]
    formatted, errors = run_black([python for python, _ in translated])

    changed = {}
    for file, source, (_, swapped), python, error in zip(
        files, sources, translated, formatted, errors
    ):
        if error:
            print(
                f"{os.path.relpath(file)}: black can't parse it: {error}",
                file=sys.stderr,
            )
        elif (text := from_python(python, swapped)) != source:
            changed[file] = text
    failed = any(errors)

    if not args.fix:
        for file, text in changed.items():
            name = os.path.relpath(file)
            sys.stdout.writelines(
                difflib.unified_diff(
                    sources[files.index(file)].splitlines(keepends=True),
                    text.splitlines(keepends=True),
                    name,
                    f"{name} (black)",
                )
            )
        print(f"{len(changed)} of {len(files)} files would be reformatted")
        sys.exit(1 if changed or failed else 0)

    if changed:
        check_compiled_output(changed)
    for file, text in changed.items():
        file.write_text(text)
        print(f"reformatted {os.path.relpath(file)}")
    print(f"{len(changed)} of {len(files)} files reformatted")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()

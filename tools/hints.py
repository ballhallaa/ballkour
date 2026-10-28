#!/usr/bin/env python3
"""Manage the hint routes compiled into each course (src/hints/<course>.opy).

Recording workflow:
  1. Once: in Options > Gameplay > General, turn on "Enable Workshop Inspector Log
     File". Overwatch then writes each match's Inspector log to
     C:/Documents/Overwatch/Workshop on Windows, or ~/.steam/steam/steamapps/compatdata/2357570/pfx/drive_c/users/steamuser/Documents/Overwatch/Workshop/ 
     on Linux.
  2. Compile the course from develop: the Hint Recorder is only in dev builds, whose
     src/VERSION ends in -dev, and release builds leave it out. In the course's
     Workshop Settings, turn on "Hint Recorder", then host the lobby.
  3. Play checkpoints normally. Completing a checkpoint saves the path you took as
     its hint, starting from where you were last at rest in the checkpoint ring (or from
     arriving, if you carry momentum in), so setups like walljumps are included.
     Go back a checkpoint to preview a route; complete the checkpoint
     again to replace it. Press Next CP to skip checkpoints you're happy with.
  4. Import the newest Inspector log:
       python3 tools/hints.py import <map>
     View all valid arguments for maps:
       python3 tools/hints.py status
     Then recompile the course (OverPy: Compile).
     If routes are missing, leave the lobby first so Overwatch finishes the log.

Alternatively, in the Workshop Inspector set the variable target to Global, click
"Copy to clipboard current variables for current variable target as Workshop
actions", and import that from a file (or - for stdin):
       python3 tools/hints.py import <map> export.txt

Routes already in the hints file are kept unless the import has a different route
for that checkpoint, so a course can be recorded across several sessions. To record a 
course from scratch and only see the new routes in-game, clear it first:
       python3 tools/hints.py clear <map>
Then recompile the course (OverPy: Compile).
"""

import argparse
import math
import re
import sys
from pathlib import Path

from overpy import SRC, compile_files, courses, find_course, fold

ELEMENT_LIMIT = 32768
CPS_PER_RULE = 10
# Stands in for the anchor of an action that isn't a grapple
NO_ANCHOR = (0.0, 0.0, 0.0)

DATA_RE = re.compile(r"^\s*hintData\[(\d+)\] = compress\(\[(.*)\]\)\s*$")
VECT_RE = re.compile(r"vect\(([^,]+),([^,]+),([^)]+)\)")
RULE_RE = re.compile(r'^rule "(.*?)(?: \(CPs \d+-\d+\))?":\s*$')
CP_RE = re.compile(r"^\s*cps\[(\d+)\] =", re.M)
NUMBER_RE = re.compile(r"-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?")
WORD_RE = re.compile(r"[A-Za-z][A-Za-z ]*")
LOG_LINE_RE = re.compile(r"\bhint (\d+) (start|point|action|end)\b(.*)")
WELCOME_RE = re.compile(r"Welcome to Ballkour's (.+?) course")
WORKSHOP_LOG_DIRS = [
    "~/.local/share/Steam/steamapps/compatdata/2357570/pfx/drive_c/users/steamuser/Documents/Overwatch/Workshop",
    "~/.steam/steam/steamapps/compatdata/2357570/pfx/drive_c/users/steamuser/Documents/Overwatch/Workshop",
    "~/Documents/Overwatch/Workshop",
]


def hints_path(course):
    return SRC / "hints" / course.name


def parse_vects(text):
    return [tuple(float(c) for c in v) for v in VECT_RE.findall(text)]


def read_hints(path):
    """Returns the rules' name and {cp: (points, times, actions, anchors)}, where
    anchors[j] is where actions[j] grappled to, or None."""
    name = "Hint Routes"
    hints = {}
    lines = path.read_text().splitlines() if path.exists() else []
    for line in lines:
        if m := RULE_RE.match(line):
            name = m[1]
        elif m := DATA_RE.match(line):
            cp, (header, *rest) = int(m[1]), parse_vects(m[2])
            keyframes, action_count, anchor_count = (int(c) for c in header)
            time_vects = math.ceil(keyframes / 3)
            if len(rest) != keyframes + time_vects + action_count + anchor_count or (
                anchor_count not in (0, action_count)
            ):
                sys.exit(f"{path}: hintData[{cp}] doesn't match its vect(keyframes, actions, anchors)")
            points = rest[:keyframes]
            if not points:
                continue
            times = [t for v in rest[keyframes : keyframes + time_vects] for t in v][:keyframes]
            actions = rest[keyframes + time_vects :][:action_count]
            anchors = [None if a == NO_ANCHOR else a for a in rest[len(rest) - anchor_count :]]
            hints[cp] = points, times, actions, anchors or [None] * action_count
    return name, hints


def fmt(number, places):
    text = f"{number:.{places}f}".rstrip("0").rstrip(".")
    return "0" if text == "-0" else text


def vects(values):
    return ", ".join(f"vect({', '.join(fmt(c, 2) for c in v)})" for v in values)


def pack(points, times, actions, anchors):
    """The route as hintData stores it (see the comments write_hints adds)."""
    anchors = [a or NO_ANCHOR for a in anchors] if any(anchors) else []
    padded = list(times) + [0] * (-len(times) % 3)
    time_vects = [tuple(padded[k : k + 3]) for k in range(0, len(padded), 3)]
    return [(len(points), len(actions), len(anchors)), *points, *time_vects, *actions, *anchors]


def write_hints(path, name, hints):
    comments = [
        "    # Generated by tools/hints.py: record routes in-game and import them instead of editing by hand.",
        "    # hintData[i]: the route from cps[i] to cps[i + 1] as one compressed vector array, which",
        "    # Hints: Decompress Routes unpacks: vect(keyframe count, action count, anchor count), then",
        "    # hintRoutes[i]: keyframe positions, interpolated in time during playback",
        "    # hintTimes[i]: seconds into the route of each keyframe, three to a vector",
        "    # hintActions[i]: vect(startTime, endTime, action) in seconds into the route; action indexes hintColors",
        "    # hintAnchors[i][j]: where hintActions[i][j] grappled to, or vect(0, 0, 0) if it isn't a grapple (none if nothing grapples)",
    ]
    lines = []
    for first in range(0, max(hints, default=0) + 1, CPS_PER_RULE):
        chunk = [cp for cp in sorted(hints) if first <= cp < first + CPS_PER_RULE]
        if not chunk:
            continue
        if lines:
            lines += ["", ""]
        lines.append(f'rule "{name} (CPs {first}-{first + CPS_PER_RULE - 1})":')
        if len(lines) == 1:
            lines += comments
        for cp in chunk:
            lines.append(f"    hintData[{cp}] = compress([{vects(pack(*hints[cp]))}])")
    if not lines:
        lines = [f'rule "{name}":', *comments, "    hintData = []"]
    path.parent.mkdir(exist_ok=True)
    path.write_text("\n".join(lines) + "\n")


class ExportParser:
    """Reads values from the Inspector's "copy as Workshop actions" text."""

    def __init__(self, text):
        self.text = text

    def array(self, name, required=True):
        m = re.search(rf"\b{name}\b\s*[=,]\s*", self.text, re.I)
        if not m:
            if not required:
                return []
            sys.exit(
                f"No '{name}' in the export. In the Workshop Inspector, set the variable"
                " target to Global and copy the current variables as Workshop actions."
            )
        self.pos = m.end()
        value = self.value()
        return value if isinstance(value, list) else []

    def value(self):
        self.skip_space()
        if self.take("Empty Array"):
            return []
        if self.take("Array("):
            return self.arguments()
        if self.take("Vector("):
            vector = tuple(self.arguments())
            if len(vector) != 3 or None in vector:
                self.fail("a vector of three numbers")
            return vector
        if m := NUMBER_RE.match(self.text, self.pos):
            self.pos = m.end()
            return float(m[0])
        if m := WORD_RE.match(self.text, self.pos):
            self.pos = m.end()
            return None
        self.fail("a value")

    def arguments(self):
        items = []
        self.skip_space()
        if self.take(")"):
            return items
        while True:
            items.append(self.value())
            self.skip_space()
            if self.take(")"):
                return items
            if not self.take(","):
                self.fail("',' or ')'")

    def skip_space(self):
        while self.pos < len(self.text) and self.text[self.pos].isspace():
            self.pos += 1

    def take(self, token):
        if self.text.startswith(token, self.pos):
            self.pos += len(token)
            return True
        return False

    def fail(self, expected):
        snippet = self.text[self.pos : self.pos + 40]
        sys.exit(f"Couldn't read the export: expected {expected} at '{snippet}'")


def spline_point(points, times, i, t):
    """Where the game puts the orb at time t between keyframes i and i + 1: a cubic Hermite
    spline whose velocity at each keyframe comes from its neighbours."""
    last = len(points) - 1
    h = times[i + 1] - times[i]
    s = (t - times[i]) / h

    def velocity(k):
        a, b = max(k - 1, 0), min(k + 1, last)
        return [(pb - pa) * h / (times[b] - times[a]) for pa, pb in zip(points[a], points[b])]

    weights = (2 * s**3 - 3 * s**2 + 1, 3 * s**2 - 2 * s**3, s**3 - 2 * s**2 + s, s**3 - s**2)
    terms = (points[i], points[i + 1], velocity(i), velocity(i + 1))
    return [sum(w * term[c] for w, term in zip(weights, terms)) for c in range(3)]


def worst_miss(points, times, kept):
    """How far the spline through the kept keyframes strays from the recording, and where."""
    keys, key_times = [points[k] for k in kept], [times[k] for k in kept]
    worst, worst_k, segment = 0, None, 0
    for k in range(len(points)):
        while segment < len(kept) - 2 and times[k] > key_times[segment + 1]:
            segment += 1
        miss = math.dist(points[k], spline_point(keys, key_times, segment, times[k]))
        if miss > worst:
            worst, worst_k = miss, k
    return worst, worst_k


def simplify(points, times, tolerance, max_gap):
    """Adds the sample the spline misses most until every sample is within tolerance, then
    drops the keyframes it can do without. Returns (points, times)."""
    kept = [0]
    for k in range(1, len(points)):
        if times[k] - times[kept[-1]] > max_gap and k - 1 > kept[-1]:
            kept.append(k - 1)
    if kept[-1] != len(points) - 1:
        kept.append(len(points) - 1)
    while (miss := worst_miss(points, times, kept))[0] > tolerance:
        kept = sorted(kept + [miss[1]])
    dropped = True
    while dropped:
        dropped = False
        for k in kept[1:-1]:
            i = kept.index(k)
            trial = kept[:i] + kept[i + 1 :]
            if (
                times[trial[i]] - times[trial[i - 1]] <= max_gap
                and worst_miss(points, times, trial)[0] <= tolerance
            ):
                kept, dropped = trial, True
    return round_vects(points[k] for k in kept), [round(times[k], 2) for k in kept]


def round_vects(values):
    return [None if v is None else tuple(round(c, 2) for c in v) for v in values]


def cp_entry(values, cp):
    """An exported per-CP array, or [] for CPs never set (which export as 0)."""
    value = values[cp] if cp < len(values) else []
    return value if isinstance(value, list) else []


def same_route(a, b):
    return len(a) == len(b) and all(
        abs(ca - cb) <= 0.011 for pa, pb in zip(a, b) for ca, cb in zip(pa, pb)
    )


def cp_count(course):
    return max(int(i) for i in CP_RE.findall(course.read_text())) + 1


def format_ranges(numbers):
    ranges, start = [], None
    for i, n in enumerate(numbers):
        start = n if start is None else start
        if i + 1 == len(numbers) or numbers[i + 1] != n + 1:
            ranges.append(str(n) if start == n else f"{start}-{n}")
            start = None
    return ", ".join(ranges)


def compile_elements(course):
    """Compiles the course with the installed OverPy extension, if there is one."""
    results = compile_files([course])
    if results is None:
        return None
    if "error" in results[0]:
        print(f"  OverPy compile failed: {results[0]['error']}")
        return None
    return results[0]["nbElements"]


def print_status(course):
    _, hints = read_hints(hints_path(course))
    needed = cp_count(course) - 1
    missing = [cp for cp in range(needed) if cp not in hints]
    points = sum(len(route) for route, _, _, _ in hints.values())
    actions = sum(len(spans) for _, _, spans, _ in hints.values())
    anchors = sum(
        a is not None for _, _, _, cp_anchors in hints.values() for a in cp_anchors
    )
    print(
        f"{course.stem}: {needed - len(missing)}/{needed} CPs have hints,"
        f" {points} keyframes + {actions} actions + {anchors} grapple anchors"
    )
    if missing:
        print(f"  missing: {format_ranges(missing)}")
    elements = compile_elements(course)
    if elements is not None:
        warning = "  <-- over the Workshop limit!" if elements > ELEMENT_LIMIT else ""
        print(f"  workshop elements: {elements}/{ELEMENT_LIMIT}{warning}")


def is_other_course(text, course):
    welcome = WELCOME_RE.search(text)
    return welcome and not all(
        word in fold(welcome[1]) for word in fold(course.stem).split("-")[1:]
    )


def newest_log(course):
    """The newest Inspector log with recorded routes for the course."""
    logs = sorted(
        (log for folder in WORKSHOP_LOG_DIRS for log in Path(folder).expanduser().glob("*.txt")),
        key=lambda log: log.stat().st_mtime,
        reverse=True,
    )
    for log in logs:
        text = read_text(log)
        if not is_other_course(text, course) and re.search(r"\bhint \d+ end\b", text):
            return log, text
    sys.exit(
        f"No Workshop Inspector log has recorded routes for {course.stem}. Turn on Options >"
        ' Gameplay > General > "Enable Workshop Inspector Log File", record, then leave'
        " the lobby."
    )


def read_text(path):
    data = path.read_bytes()
    if data[:2] in (b"\xff\xfe", b"\xfe\xff"):
        return data.decode("utf-16")
    return data.decode("utf-8-sig", errors="replace")


def recordings_from_log(text):
    """Yields (cp, points, times, actions, anchors) for the last complete recording of
    each CP in an Inspector log file."""
    recordings, current = {}, {}
    for line in text.splitlines():
        if not (m := LOG_LINE_RE.search(line)):
            continue
        cp, kind = int(m[1]), m[2]
        numbers = [float(n) for n in NUMBER_RE.findall(m[3])]
        if kind == "start":
            current[cp] = int(numbers[0]), [], [], [], []
        elif cp not in current:
            continue
        elif kind == "point":
            if len(numbers) != 4:
                del current[cp]
                continue
            current[cp][1].append(numbers[0])
            current[cp][2].append(tuple(numbers[1:]))
        elif kind == "action":
            current[cp][3].append(tuple(numbers[:3]))
            current[cp][4].append(tuple(numbers[3:6]) if len(numbers) >= 6 else None)
        else:
            count, times, points, actions, anchors = current.pop(cp)
            if len(points) == count >= 2:
                recordings[cp] = points, times, actions, anchors
    for cp, recording in sorted(recordings.items()):
        yield cp, *recording


def recordings_from_export(text):
    """Yields (cp, points, times, actions, anchors) from an Inspector "copy as Workshop
    actions" export."""
    parser = ExportParser(text)
    routes = parser.array("hintRoutes")
    all_times = parser.array("hintTimes")
    all_actions = parser.array("hintActions", required=False)
    all_anchors = parser.array("hintAnchors", required=False)
    for cp, route in enumerate(routes):
        if not isinstance(route, list) or len(route) < 2:
            continue
        times = cp_entry(all_times, cp)
        if len(times) != len(route):
            continue
        actions = cp_entry(all_actions, cp)
        anchors = cp_entry(all_anchors, cp)
        anchors = [
            anchors[j] if j < len(anchors) and isinstance(anchors[j], tuple) else None
            for j in range(len(actions))
        ]
        yield cp, route, times, actions, anchors


def import_recordings(args):
    course = find_course(args.course)
    if args.file == "-":
        source, text = "stdin", sys.stdin.read()
    elif args.file:
        source, text = args.file, read_text(Path(args.file))
    else:
        log, text = newest_log(course)
        source = log.name
    if is_other_course(text, course):
        sys.exit(f"{source} is a {WELCOME_RE.search(text)[1]} log, not {course.stem}")
    is_log = WELCOME_RE.search(text) or LOG_LINE_RE.search(text)
    recordings = list((recordings_from_log if is_log else recordings_from_export)(text))
    print(f"Importing {len(recordings)} recorded routes from {source}")
    path = hints_path(course)
    name, hints = read_hints(path)
    needed = cp_count(course) - 1
    for cp, route, times, actions, anchors in recordings:
        if cp >= needed:
            print(f"CP {cp}: skipped, {course.stem} only has CPs 0-{needed - 1}")
            continue
        if not is_log and cp in hints and same_route(hints[cp][0], route):
            continue
        points, times = simplify(route, times, args.tolerance, args.max_gap)
        hint = points, times, round_vects(actions), round_vects(anchors)
        if hints.get(cp) == hint:
            continue
        hints[cp] = hint
        print(
            f"CP {cp}: {len(route)} -> {len(points)} keyframes over {times[-1]}s,"
            f" {len(actions)} actions"
        )
    write_hints(path, name, hints)
    print_status(course)


def remove(args):
    course = find_course(args.course)
    path = hints_path(course)
    name, hints = read_hints(path)
    for cp in args.cps:
        if hints.pop(cp, None) is None:
            print(f"CP {cp}: no hint to remove")
    write_hints(path, name, hints)
    print_status(course)


def clear(args):
    course = find_course(args.course)
    path = hints_path(course)
    name, _ = read_hints(path)
    write_hints(path, name, {})
    print_status(course)


def status(args):
    for course in [find_course(c) for c in args.courses] or courses():
        print_status(course)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    commands = parser.add_subparsers(required=True)

    import_parser = commands.add_parser(
        "import", help="merge routes from a Workshop Inspector log or export"
    )
    import_parser.add_argument("course", help="course file or part of its name")
    import_parser.add_argument(
        "file",
        nargs="?",
        help="Inspector log file or clipboard export, or - for stdin (default: the"
        " newest Inspector log file)",
    )
    import_parser.add_argument(
        "--tolerance",
        type=float,
        default=0.5,
        help="max distance in meters a simplified route may stray (default: 0.5)",
    )
    import_parser.add_argument(
        "--max-gap",
        type=float,
        default=1.0,
        help="max seconds between keyframes (default: 1.0)",
    )
    import_parser.set_defaults(run=import_recordings)

    remove_parser = commands.add_parser("remove", help="delete hints for CPs")
    remove_parser.add_argument("course", help="course file or part of its name")
    remove_parser.add_argument("cps", nargs="+", type=int, metavar="cp")
    remove_parser.set_defaults(run=remove)

    clear_parser = commands.add_parser("clear", help="delete every hint for a course")
    clear_parser.add_argument("course", help="course file or part of its name")
    clear_parser.set_defaults(run=clear)

    status_parser = commands.add_parser(
        "status", help="show hint coverage and element usage"
    )
    status_parser.add_argument("courses", nargs="*", metavar="course")
    status_parser.set_defaults(run=status)

    args = parser.parse_args()
    args.run(args)


if __name__ == "__main__":
    main()

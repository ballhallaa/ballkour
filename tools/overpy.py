"""Finds the courses and compiles them with the OverPy VS Code extension's compiler."""

import glob
import json
import os
import re
import shutil
import subprocess
from pathlib import Path

SRC = Path(__file__).resolve().parent.parent / "src"

# A course is a top-level file that pulls in the engine
COURSE_RE = re.compile(r'^#!include "ballkour\.opy"', re.M)
COMPILE_SCRIPT = """
const [overpyPath, ...files] = process.argv.slice(1);
const overpy = require(overpyPath), fs = require("fs"), path = require("path");
const write = (text) => process.stdout.write(text);
console.log = console.error;
overpy.readyPromise.then(async () => {
    const results = [];
    for (const file of files) {
        try {
            const { result, nbElements } = await overpy.compile(
                fs.readFileSync(file, "utf8"), "en-US", path.dirname(file) + "/", path.basename(file)
            );
            results.push({ result, nbElements });
        } catch (error) {
            results.push({ error: String(error.message ?? error) });
        }
    }
    write(JSON.stringify(results));
});
"""


def courses(src=SRC):
    return sorted(p for p in src.glob("*.opy") if COURSE_RE.search(p.read_text()))


def compile_files(paths):
    """Compiles each file, returning {"result", "nbElements"} or {"error"} for each.

    Returns None if node or the OverPy extension isn't installed.
    """
    overpy = glob.glob(
        os.path.expanduser("~/.vscode*/extensions/zezombye.overpy-*/npm/overpy.js")
    )
    if not overpy or not shutil.which("node"):
        return None
    result = subprocess.run(
        ["node", "-e", COMPILE_SCRIPT, max(overpy, key=os.path.getmtime)]
        + [str(p) for p in paths],
        capture_output=True,
        text=True,
    )
    if result.returncode:
        raise RuntimeError(f"OverPy compiler crashed: {result.stderr.strip()}")
    return json.loads(result.stdout)

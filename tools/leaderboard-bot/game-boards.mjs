// The remakes' in-game top 10s (their .opy files) only change with a release, while runs sent from the website go on
// the boards straight away. This prints the lines for every .opy file that's behind its board, and for its assisted
// top 10 (assistedLb), which the lobby shows under its Assisted tab:
//   node game-boards.mjs
// Paste them over the file's lb[…] and lbRunInfo(…) lines, or assistedLb[…] and assistedLbRunInfo(…), before a
// release, then pad each name as usual. assistedLbRunInfo(…) lines go in loadRunInfo with the others.
import fs from "node:fs";
import path from "node:path";
import { REPO, loadCourses, parseOpy, groundText } from "./boards.mjs";
import { standings } from "./ratings.mjs";

// The third field of a board's line: a run's mistakes, or on the assisted board, its ground time, written the way the
// lobby shows it ("12.34", under the Piledriver's icon), which parseOpy() reads back as ground
const third = (r) => (Number.isInteger(r.ground) ? groundText(r.ground) : r.mistakes);
const sameRuns = (a, b) => a.length === b.length && a.every((r, i) =>
  r.name === b[i].name && r.time === b[i].time && third(r) === third(b[i]) && r.discord === b[i].discord);
const assisted = new Map(loadCourses({ assisted: true }).map((c) => [c.n, c]));
let behind = 0;
for (const c of loadCourses()) {
  if (!c.course.file.endsWith(".opy")) continue;
  if (!c.ok) { console.error(`Couldn't read ${c.course.file}`); continue; }
  const inGame = parseOpy(fs.readFileSync(path.join(REPO, c.course.file), "utf8"), "assistedLb");
  if (!inGame) { console.error(`${c.course.file} has no assistedLb = [] to read its assisted top 10 from`); continue; }
  for (const [board, file, top] of [["lb", c.file, standings(c).top], ["assistedLb", inGame, standings(assisted.get(c.n)).top]]) {
    if (sameRuns(file, top)) continue;
    behind++;
    console.log(`\n${c.course.file} (${c.n} ${c.course.name}${board === "lb" ? "" : ", assisted"}):\n`);
    top.forEach((r, i) => console.log(`    ${board}[${i + 1}] = "${r.name.toUpperCase()}, ${r.time}, ${third(r)}, ''"${r.discord ? `  # discord: ${r.discord}` : ""}`));
    console.log("");
    top.forEach((r, i) => console.log(`    ${board}RunInfo(${i + 1}, "${r.date}", "${r.video.replace(/^https:\/\//, "")}")`));
  }
}
console.log(behind ? "\nPad each name as usual before releasing." : "Every in-game board is up to date.");

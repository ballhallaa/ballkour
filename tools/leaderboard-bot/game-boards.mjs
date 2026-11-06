// The remakes' in-game top 10s (their .opy files) only change with a release, while runs sent from the website go on
// the boards straight away. This prints the lines for every .opy file that's behind its board:
//   node game-boards.mjs
// Paste them over the file's lb[…] and lbRunInfo(…) lines before a release, then pad each name as usual.
import { loadCourses } from "./boards.mjs";
import { standings } from "./ratings.mjs";

const sameRuns = (a, b) => a.length === b.length && a.every((r, i) =>
  r.name === b[i].name && r.time === b[i].time && r.mistakes === b[i].mistakes && r.discord === b[i].discord);
let behind = 0;
for (const c of loadCourses()) {
  if (!c.course.file.endsWith(".opy")) continue;
  if (!c.ok) { console.error(`Couldn't read ${c.course.file}`); continue; }
  const top = standings(c).top;
  if (sameRuns(c.file, top)) continue;
  behind++;
  console.log(`\n${c.course.file} (${c.n} ${c.course.name}):\n`);
  top.forEach((r, i) => console.log(`    lb[${i + 1}] = "${r.name.toUpperCase()}, ${r.time}, ${r.mistakes}, ''"${r.discord ? `  # discord: ${r.discord}` : ""}`));
  console.log("");
  top.forEach((r, i) => console.log(`    lbRunInfo(${i + 1}, "${r.date}", "${r.video.replace(/^https:\/\//, "")}")`));
}
console.log(behind ? "\nPad each name as usual before releasing." : "Every in-game board is up to date.");

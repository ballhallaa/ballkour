// The remakes' in-game top 10s (their .opy files) only change with a release, while runs sent from the website go on
// the boards straight away. This prints the lines for every .opy file that's behind its board, and for its assisted
// top 10 (assistedLb), which the lobby shows under its Assisted tab:
//   node game-boards.mjs
// Paste them over the file's lb[…] and lbRunInfo(…) lines, or assistedLb[…] and assistedLbRunInfo(…), before a
// release. assistedLbRunInfo(…) lines go in loadRunInfo with the others.
// A name keeps the padding it has at the same rank on any in-game board, as the padding lines up the rows' times
// after "rank. name". Names padded only at another rank, or nowhere yet, are listed at the end to pad as usual.
// todo.mjs uses behindBoards() for the daily message listing them.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { REPO, loadCourses, parseOpy, groundText } from "./boards.mjs";
import { standings } from "./ratings.mjs";

// The third field of a board's line: a run's mistakes, or on the assisted board, its ground time, written the way the
// lobby shows it ("12.34", under the Piledriver's icon), which parseOpy() reads back as ground
const third = (r) => (Number.isInteger(r.ground) ? groundText(r.ground) : r.mistakes);
const sameRuns = (a, b) => a.length === b.length && a.every((r, i) =>
  r.name === b[i].name && r.time === b[i].time && third(r) === third(b[i]) && r.discord === b[i].discord);

// The padding of every name on the in-game boards: name → [{ rank, pad, file, board }, …]
function knownPadding() {
  const out = new Map();
  const dir = path.join(REPO, "leaderboards");
  for (const f of fs.readdirSync(dir).filter((f) => f.endsWith(".opy"))) {
    const text = fs.readFileSync(path.join(dir, f), "utf8");
    for (const m of text.matchAll(/(?<![A-Za-z0-9_])(lb|assistedLb)\[(\d+)\]\s*=\s*"([^",]*),[^"]*'([^']*)'\s*"/g)) {
      const name = m[3].trim().toUpperCase();
      if (!out.has(name)) out.set(name, []);
      out.get(name).push({ rank: Number(m[2]), pad: m[4], file: `leaderboards/${f}`, board: m[1] });
    }
  }
  return out;
}

// A run's padding at rank on a board: the same rank anywhere, or else (to check) another rank, on this board first
function padding(known, name, rank, file, board) {
  const seen = known.get(name) || [];
  const exact = seen.find((s) => s.rank === rank);
  if (exact) return { pad: exact.pad };
  const near = seen.find((s) => s.file === file && s.board === board) || seen[0];
  return near ? { pad: near.pad, from: near } : { pad: "" };
}

// Every in-game board that's behind the course's board: [{ course, board: "lb" or "assistedLb", top: [run, …] }, …],
// in course order, the unassisted board before the assisted one
export function behindBoards() {
  const assisted = new Map(loadCourses({ assisted: true }).map((c) => [c.n, c]));
  const out = [];
  for (const c of loadCourses()) {
    if (!c.course.file.endsWith(".opy")) continue;
    if (!c.ok) { console.error(`Couldn't read ${c.course.file}`); continue; }
    const inGame = parseOpy(fs.readFileSync(path.join(REPO, c.course.file), "utf8"), "assistedLb");
    if (!inGame) { console.error(`${c.course.file} has no assistedLb = [] to read its assisted top 10 from`); continue; }
    for (const [board, file, top] of [["lb", c.file, standings(c).top], ["assistedLb", inGame, standings(assisted.get(c.n)).top]]) {
      if (!sameRuns(file, top)) out.push({ course: c.course, board, top });
    }
  }
  return out;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const behind = behindBoards();
  const known = knownPadding();
  const toPad = [];
  for (const { course, board, top } of behind) {
    const where = `${course.file}${board === "lb" ? "" : " (assisted)"}`;
    console.log(`\n${course.file} (${course.n} ${course.name}${board === "lb" ? "" : ", assisted"}):\n`);
    top.forEach((r, i) => {
      const name = r.name.toUpperCase();
      const { pad, from } = padding(known, name, i + 1, course.file, board);
      if (from) toPad.push(`${where}: ${name} at rank ${i + 1} kept their rank ${from.rank} padding (${from.file}${from.board === "lb" ? "" : ", assisted"})`);
      else if (!pad) toPad.push(`${where}: ${name} at rank ${i + 1} has no padding yet`);
      console.log(`    ${board}[${i + 1}] = "${name}, ${r.time}, ${third(r)}, '${pad}'"${r.discord ? `  # discord: ${r.discord}` : ""}`);
    });
    console.log("");
    top.forEach((r, i) => console.log(`    ${board}RunInfo(${i + 1}, "${r.date}", "${r.video.replace(/^https:\/\//, "")}")`));
  }
  if (!behind.length) console.log("Every in-game board is up to date.");
  else if (toPad.length) console.log(`\nPad these as usual before releasing:\n${toPad.map((t) => `  ${t}`).join("\n")}`);
  else console.log("\nEvery name kept its padding.");
}

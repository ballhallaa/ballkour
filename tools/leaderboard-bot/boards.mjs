// Reading the leaderboards: the course list, each course's file (.opy or .json), history.json and runs.json. Shared by
// bot.mjs (posts the boards) and roles.mjs (gives out the rating roles); ratings.mjs turns them into the boards.
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const HERE = path.dirname(fileURLToPath(import.meta.url));
export const REPO = process.env.REPO_ROOT ? path.resolve(process.env.REPO_ROOT) : path.resolve(HERE, "../..");
// history.json and runs.json live on the leaderboard-data branch, not here, so the commits ballkour.com and the bot
// make for every run stay off develop. DATA_ROOT is a checkout of that branch (the workflow makes one, and the bot
// saves history.json there). Without it, they're read from the branch as GitHub has it now, which is all the tools
// run by hand need.
export const DATA_BRANCH = "leaderboard-data";
export const DATA_ROOT = process.env.DATA_ROOT ? path.resolve(process.env.DATA_ROOT) : null;
// Every board posted to Discord, by course number
export const HISTORY = "leaderboards/history.json";
// Runs that aren't in a course's own file (the runs sent from the website, and runs that never made a top 10), and
// runs taken off the boards for good, by course number:
//   { "runs": { "1": [run, …], … }, "removed": { "1": [{ "name", "discord", "time" }, …], … } }
// Runs are like the .json files'. A removed run never comes back, even from an old board in history.json.
// A run played in Assist Mode has "mode": "assisted", and is only on the course's assisted board (and a removed one
// only comes off that board). Every other run is on its regular board.
export const RUNS = "leaderboards/runs.json";
export const ASSISTED = "assisted";
let fetched = false;
// One of the files above, as text
export function readData(file) {
  if (DATA_ROOT) return fs.readFileSync(path.join(DATA_ROOT, file), "utf8");
  if (!fetched) {
    execFileSync("git", ["fetch", "--quiet", "origin", `+${DATA_BRANCH}:refs/remotes/origin/${DATA_BRANCH}`], { cwd: REPO, stdio: "inherit" });
    fetched = true;
  }
  return execFileSync("git", ["show", `origin/${DATA_BRANCH}:${file}`], { cwd: REPO, encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
}
// The server, the Top 10, Former Top 10, Legacy Top 10, and ratings heading roles' IDs (roles.mjs gives them out), the
// channel the assisted boards of courses without an assistedChannel of their own are posted to, and the courses
export const {
  guild: GUILD, roles: ROLES = {}, assistedChannel: ASSISTED_CHANNEL = "", courses: COURSES,
} = JSON.parse(fs.readFileSync(path.join(HERE, "courses.json"), "utf8"));

export const TIME = /^(\d{1,2}:)?\d{1,2}:\d{2}\.\d{2}$/;
export const DISCORD_ID = /^\d{17,20}$/;
const MONTHS = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"];
// "YYYY-MM-DD" stays as it is; "Mon D, YYYY" becomes YYYY-MM-DD
export function isoDate(s) {
  const str = String(s || "").trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(str)) return str;
  const m = /^([A-Za-z]{3})[a-z]*\.?\s+(\d{1,2}),\s*(\d{4})$/.exec(str);
  const mi = m ? MONTHS.indexOf(m[1].toLowerCase()) : -1;
  return mi >= 0 ? `${m[3]}-${String(mi + 1).padStart(2, "0")}-${m[2].padStart(2, "0")}` : "";
}
export const toSeconds = (t) => t.split(":").reduce((sum, part) => sum * 60 + Number(part), 0);
const byTime = (a, b) => toSeconds(a.time) - toSeconds(b.time) || a.mistakes - b.mistakes;

// lb[i] = "NAME, M:SS.cc, MISTAKES, '...'"  # discord: ID
// and lbRunInfo(rank, "YYYY-MM-DD", "host/path"), the same as the website reads. With board "assistedLb", the
// in-game assisted top 10 instead (assistedLb[i] and assistedLbRunInfo), which only game-boards.mjs reads: the
// assisted boards are made from runs.json alone.
export function parseOpy(text, board = "lb") {
  const at = `(?<![A-Za-z0-9_])${board}`;
  if (!new RegExp(`${at}\\s*=\\s*\\[\\s*\\]`).test(text)) return null; // file layout changed: don't guess
  const rows = [];
  for (const m of text.matchAll(new RegExp(`${at}\\[(\\d+)\\]\\s*=\\s*"([^"]*)"(?:[ \\t]*#[ \\t]*discord:[ \\t]*(\\d{17,20})\\b)?`, "g"))) {
    const [name, time, miss] = m[2].split(",").map((s) => s.trim());
    if (name && TIME.test(time) && /^\d+$/.test(miss)) rows[Number(m[1])] = { name, discord: m[3] || "", time, mistakes: Number(miss), date: "", video: "" };
  }
  for (const m of text.matchAll(new RegExp(`${at}RunInfo\\(\\s*(\\d+)\\s*,\\s*"([^"]*)"\\s*,\\s*"([^"]*)"\\s*\\)`, "g"))) {
    const r = rows[Number(m[1])];
    if (!r) continue;
    r.date = isoDate(m[2]);
    if (/^[a-z0-9.-]+\.[a-z]{2,}(\/[^\s"'<>]*)?$/i.test(m[3])) r.video = "https://" + m[3];
  }
  return rows.filter(Boolean).slice(0, 10);
}
// { "name", "discord", "time", "mistakes", "date", "video" }, as in the classic courses' files → a clean run, or null
// A legacy run, timed to the second ("4:30.--") with no date or video → a clean run, or null
const LEGACY_TIME = /^(\d{1,2}:)?\d{1,2}:\d{2}(\.--|\.\d{2})?$/;
function cleanLegacy(r) {
  if (!r || typeof r.name !== "string" || !r.name.trim() || !LEGACY_TIME.test(r.time) || !Number.isInteger(r.mistakes) || r.mistakes < 0) return null;
  return { name: r.name.trim(), discord: DISCORD_ID.test(r.discord) ? r.discord : "", time: r.time, mistakes: r.mistakes, date: "", video: "" };
}
export function cleanRun(r) {
  if (!r || typeof r.name !== "string" || !r.name.trim() || !TIME.test(r.time) || !Number.isInteger(r.mistakes) || r.mistakes < 0) return null;
  return {
    name: r.name.trim(),
    discord: DISCORD_ID.test(r.discord) ? r.discord : "",
    time: r.time,
    mistakes: r.mistakes,
    date: isoDate(r.date),
    video: typeof r.video === "string" && /^https:\/\/[^\s"'<>]+$/.test(r.video) ? r.video : "",
  };
}
// Every run in a classic course's file, fastest first
function jsonRuns(text) {
  let runs;
  try { runs = JSON.parse(text); } catch { return null; }
  if (!Array.isArray(runs)) return null;
  return runs.map(cleanRun).filter(Boolean).sort(byTime);
}
function courseText(course) {
  const file = path.join(REPO, course.file);
  return fs.existsSync(file) ? fs.readFileSync(file, "utf8") : null;
}
// A removed run: its player (name, and Discord ID if it has one) and time are enough to find it
function cleanRemoved(r) {
  if (!r || typeof r.name !== "string" || !r.name.trim() || !TIME.test(r.time)) return null;
  return { name: r.name.trim(), discord: DISCORD_ID.test(r.discord) ? r.discord : "", time: r.time };
}
// runs.json → { runs: { n: [run, …] }, removed: { n: [run, …] } }, with either the assisted runs or the rest
function extraData(assisted) {
  const data = JSON.parse(readData(RUNS));
  const byCourse = (obj, clean) => Object.fromEntries(Object.entries(obj && typeof obj === "object" ? obj : {})
    .filter(([, list]) => Array.isArray(list))
    .map(([n, list]) => [n, list.filter((r) => !!r && (r.mode === ASSISTED) === assisted).map(clean).filter(Boolean)]));
  return { runs: byCourse(data && data.runs, cleanRun), removed: byCourse(data && data.removed, cleanRemoved) };
}
// Every course with what its board is made of, for ratings.mjs:
//   { course, n, broken, ok, file: [run, …], more: [run, …], removed: [run, …], boards: [[run, …], …] }
// ok is false when the course's file is missing or its layout changed, so nothing is guessed from it.
// assisted: the assisted boards instead, from the assisted runs in runs.json alone (the courses' own files only have
// regular runs) and the assisted boards posted before (history.json's "assisted"). legacy: the legacy boards instead
// (history.json's "legacy", from before May 2026), for the Legacy rating: only the courses with one, each made of its
// legacy board alone, and counted whether or not the course works now, as its board can't change any more. It's the
// same as the website's (legacyOf in index.html).
export function loadCourses({ assisted = false, legacy = false } = {}) {
  const history = JSON.parse(readData(HISTORY));
  if (legacy) {
    return COURSES.map((course) => {
      const list = history[course.n] && Array.isArray(history[course.n].legacy) ? history[course.n].legacy : [];
      return { course, n: course.n, broken: false, ok: true, file: list.map(cleanLegacy).filter(Boolean), more: [], removed: [], boards: [] };
    }).filter((c) => c.file.length);
  }
  const { runs, removed } = extraData(assisted);
  const posted = assisted ? ASSISTED : "boards";
  return COURSES.map((course) => {
    const text = assisted ? "" : courseText(course);
    const file = assisted ? [] : text === null ? null : course.file.endsWith(".opy") ? parseOpy(text) : jsonRuns(text);
    return {
      course,
      n: course.n,
      broken: !!course.broken,
      ok: !!file,
      file: file || [],
      more: runs[course.n] || [],
      removed: removed[course.n] || [],
      boards: ((history[course.n] && history[course.n][posted]) || []).map((b) => b.map(cleanRun).filter(Boolean)),
    };
  });
}

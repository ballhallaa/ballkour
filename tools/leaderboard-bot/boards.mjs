// Reading the leaderboards: the course list, each course's file (.opy or .json), history.json and runs.json. Shared by
// bot.mjs (posts the boards) and roles.mjs (gives out the rating roles); ratings.mjs turns them into the boards.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const HERE = path.dirname(fileURLToPath(import.meta.url));
export const REPO = process.env.REPO_ROOT ? path.resolve(process.env.REPO_ROOT) : path.resolve(HERE, "../..");
export const HISTORY = path.join(REPO, "leaderboards/history.json");
// Runs that aren't in a course's own file (the runs sent from the website, and runs that never made a top 10), and
// runs taken off the boards for good, by course number:
//   { "runs": { "1": [run, …], … }, "removed": { "1": [{ "name", "discord", "time" }, …], … } }
// Runs are like the .json files'. A removed run never comes back, even from an old board in history.json.
export const RUNS = path.join(REPO, "leaderboards/runs.json");
// The server, the Top 10 and Former Top 10 roles' IDs (roles.mjs gives them out), and the courses
export const { guild: GUILD, roles: ROLES = {}, courses: COURSES } = JSON.parse(fs.readFileSync(path.join(HERE, "courses.json"), "utf8"));

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
// and lbRunInfo(rank, "YYYY-MM-DD", "host/path"), the same as the website reads
export function parseOpy(text) {
  if (!/\blb\s*=\s*\[\s*\]/.test(text)) return null; // file layout changed: don't guess
  const rows = [];
  for (const m of text.matchAll(/lb\[(\d+)\]\s*=\s*"([^"]*)"(?:[ \t]*#[ \t]*discord:[ \t]*(\d{17,20})\b)?/g)) {
    const [name, time, miss] = m[2].split(",").map((s) => s.trim());
    if (name && TIME.test(time) && /^\d+$/.test(miss)) rows[Number(m[1])] = { name, discord: m[3] || "", time, mistakes: Number(miss), date: "", video: "" };
  }
  for (const m of text.matchAll(/lbRunInfo\(\s*(\d+)\s*,\s*"([^"]*)"\s*,\s*"([^"]*)"\s*\)/g)) {
    const r = rows[Number(m[1])];
    if (!r) continue;
    r.date = isoDate(m[2]);
    if (/^[a-z0-9.-]+\.[a-z]{2,}(\/[^\s"'<>]*)?$/i.test(m[3])) r.video = "https://" + m[3];
  }
  return rows.filter(Boolean).slice(0, 10);
}
// { "name", "discord", "time", "mistakes", "date", "video" }, as in the classic courses' files → a clean run, or null
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
// runs.json → { runs: { n: [run, …] }, removed: { n: [run, …] } }. It's optional: no file means neither yet.
function extraData() {
  const data = fs.existsSync(RUNS) ? JSON.parse(fs.readFileSync(RUNS, "utf8")) : {};
  const byCourse = (obj, clean) => Object.fromEntries(Object.entries(obj && typeof obj === "object" ? obj : {})
    .filter(([, list]) => Array.isArray(list)).map(([n, list]) => [n, list.map(clean).filter(Boolean)]));
  return { runs: byCourse(data && data.runs, cleanRun), removed: byCourse(data && data.removed, cleanRemoved) };
}
// Every course with what its board is made of, for ratings.mjs:
//   { course, n, broken, ok, file: [run, …], more: [run, …], removed: [run, …], boards: [[run, …], …] }
// ok is false when the course's file is missing or its layout changed, so nothing is guessed from it.
export function loadCourses() {
  const history = JSON.parse(fs.readFileSync(HISTORY, "utf8"));
  const { runs, removed } = extraData();
  return COURSES.map((course) => {
    const text = courseText(course);
    const file = text === null ? null : course.file.endsWith(".opy") ? parseOpy(text) : jsonRuns(text);
    return {
      course,
      n: course.n,
      broken: !!course.broken,
      ok: !!file,
      file: file || [],
      more: runs[course.n] || [],
      removed: removed[course.n] || [],
      boards: ((history[course.n] && history[course.n].boards) || []).map((b) => b.map(cleanRun).filter(Boolean)),
    };
  });
}

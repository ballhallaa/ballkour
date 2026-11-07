// Posts each course's leaderboard to its Discord channel when it changes: a picture of the top 10 and a
// "Congrats @X, @Y, and @Z for the new top-10 times!" line that pings only the new runners. Then it adds the
// new board to leaderboards/history.json, which is also how it knows what it has already posted. A board is the
// course's file and the runs sent from the website (leaderboards/runs.json) together: see ratings.mjs.
//
// Run by .github/workflows/leaderboard-bot.yml. Settings come from the environment:
//   DISCORD_BOT_TOKEN  the bot's token (without it, names and pictures from Discord are left out)
//   DRY_RUN=1          draw the pictures into out/ and print the messages, but don't post or change history.json
//   FORCE_COURSE=…     post these courses' newest boards again, even if they haven't changed: a course number (3),
//                      a list (3,5,7), a range (3-12), or all. A course with no runs yet posts an empty top 10.
//   LEGACY=1           post the legacy boards (the runs from before May 2026 in history.json) to each course's
//                      legacyChannel instead: all of them, or only FORCE_COURSE's. No pings, and history.json
//                      isn't changed, so it doesn't affect which boards count as new.
//   NO_CONGRATS=1      leave out the "Congrats …" line, so nobody is pinged: for posting boards again with new
//                      pictures without pinging their runners a second time.
//   NOT_NEW=1          draw the pictures without the NEW chip and green border on new runs. The "Congrats …"
//                      line is unchanged (NO_CONGRATS leaves that out).

import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";
import { cardHtml } from "./card.mjs";
import { HERE, HISTORY, GUILD, COURSES, DISCORD_ID, loadCourses } from "./boards.mjs";
import { TOKEN, api } from "./discord.mjs";
import { standings, rate, playerKey } from "./ratings.mjs";

const OUT = path.join(HERE, "out");
const DRY = !!process.env.DRY_RUN;
// "3", "3,5,7", "3-12" or "all" → the set of course numbers, or null when nothing is forced
function forced(spec) {
  const s = String(spec || "").trim().toLowerCase();
  if (!s) return null;
  if (s === "all") return "all";
  const ns = new Set();
  for (const part of s.split(/[\s,]+/).filter(Boolean)) {
    const m = /^(\d+)(?:-(\d+))?$/.exec(part);
    if (!m) throw new Error(`Can't read the course list ${JSON.stringify(spec)}: use a number (3), a list (3,5,7), a range (3-12) or all`);
    const [a, b] = [Number(m[1]), Number(m[2] || m[1])];
    for (let n = Math.min(a, b); n <= Math.max(a, b); n++) ns.add(n);
  }
  return ns;
}
const FORCE = forced(process.env.FORCE_COURSE);
const LEGACY = !!process.env.LEGACY;
const NO_CONGRATS = !!process.env.NO_CONGRATS;
const NOT_NEW = !!process.env.NOT_NEW;

/* ---------- History ---------- */
// The player is their Discord ID when both runs have one, and their name otherwise
const samePlayer = (a, b) => (a.discord && b.discord ? a.discord === b.discord : a.name.toUpperCase() === b.name.toUpperCase());
// The runs that weren't on the board before: each old run matches one new run with the same player, time and
// mistakes, so a new run that ties an old one exactly still counts
function freshRuns(runs, before) {
  const left = [...before];
  return new Set(runs.filter((r) => {
    const i = left.findIndex((b) => b.time === r.time && b.mistakes === r.mistakes && samePlayer(b, r));
    if (i >= 0) left.splice(i, 1);
    return i < 0;
  }));
}
const sameBoard = (a, b) => a.length === b.length && !freshRuns(a, b).size;
const boardDate = (runs) => runs.map((r) => r.date).filter(Boolean).sort().pop() || "";
// One run per line, so boards stay easy to read and edit by hand
function dumpHistory(data) {
  const run = (r) => "{" + Object.entries(r).filter(([, v]) => v !== "" && v !== undefined)
    .map(([k, v]) => `${JSON.stringify(k)}: ${JSON.stringify(v)}`).join(", ") + "}";
  const entry = (e) => Object.entries(e).map(([k, v]) => {
    if (k === "legacy" && Array.isArray(v)) return `    "legacy": [\n${v.map((r) => "      " + run(r)).join(",\n")}\n    ]`;
    if (k === "boards" && Array.isArray(v)) return `    "boards": [\n${v.map((b) => `      [\n${b.map((r) => "        " + run(r)).join(",\n")}\n      ]`).join(",\n")}\n    ]`;
    return `    ${JSON.stringify(k)}: ${JSON.stringify(v)}`;
  }).join(",\n");
  return `{\n${Object.entries(data).map(([k, e]) => `  ${JSON.stringify(k)}: {\n${entry(e)}\n  }`).join(",\n")}\n}\n`;
}

/* ---------- Discord ---------- */
async function dataUri(url) {
  try {
    const res = await fetch(url);
    if (!res.ok) return "";
    return `data:${res.headers.get("content-type") || "image/png"};base64,${Buffer.from(await res.arrayBuffer()).toString("base64")}`;
  } catch {
    return "";
  }
}
// The name people see in the server (server nickname, then Discord display name, then username) and their picture
const personCache = new Map();
async function person(id) {
  if (!TOKEN || !id) return null;
  if (personCache.has(id)) return personCache.get(id);
  let member = null, user = null;
  try {
    member = await api("GET", `/guilds/${GUILD}/members/${id}`);
    user = member.user;
  } catch (e) {
    try { user = await api("GET", `/users/${id}`); } catch (e2) { // left the server, or Discord refused both lookups
      user = null;
      console.warn(`Couldn't look up Discord user ${id}, so their name and picture are left out:\n  ${e.message}\n  ${e2.message}`);
    }
  }
  let found = null;
  if (user) {
    const avatar = member && member.avatar ? `https://cdn.discordapp.com/guilds/${GUILD}/users/${id}/avatars/${member.avatar}.png?size=64`
      : user.avatar ? `https://cdn.discordapp.com/avatars/${id}/${user.avatar}.png?size=64`
      : `https://cdn.discordapp.com/embed/avatars/${Number((BigInt(id) >> 22n) % 6n)}.png`;
    found = { name: (member && member.nick) || user.global_name || user.username, avatar: await dataUri(avatar) };
  }
  personCache.set(id, found);
  return found;
}

/* ---------- The message ---------- */
const mdEscape = (s) => String(s).replace(/([\\*_~`|>#-])/g, "\\$1");
// The course's board on the website: ballkour.com/leaderboards/6 opens Dorado's top 10
const boardLink = (course) => `ballkour.com/leaderboards/${course.n}`;
function message(course, runs, fresh) {
  const newRuns = NO_CONGRATS ? [] : runs.filter((r) => fresh.has(r));
  const users = [];
  const names = newRuns.map((r) => {
    const id = DISCORD_ID.test(r.discord) ? r.discord : "";
    if (!id) return `**${mdEscape(r.name)}**`;
    if (!users.includes(id)) users.push(id);
    return `<@${id}>`;
  });
  const lines = [];
  if (names.length) {
    const list = new Intl.ListFormat("en", { style: "long", type: "conjunction" }).format(names);
    lines.push(`Congrats ${list} for the new top-10 time${names.length > 1 ? "s" : ""}!`);
  }
  lines.push(`-# Watch every run: [${boardLink(course)}](https://${boardLink(course)})`);
  return { content: lines.join("\n"), users };
}
// A legacy board: nobody is new on it, so it's posted as just the picture, with no text
const legacyMessage = () => ({ content: "", users: [] });
// A course with no runs yet: no congrats, no pings, and an invitation instead of the link to watch runs. While the
// course's route is broken nobody can take up the invitation, so it's struck through with a note saying why. Each
// line of the note needs its own "-#", since Discord's subtext only covers the line it starts.
const emptyMessage = (course) => ({
  content: course.broken
    ? "No times yet. ~~Be the first to set one!~~\n-# This course no longer works due to Overwatch's map updates.\n-# No new times can be set for now."
    : "No times yet. Be the first to set one!",
  users: [],
});
// Text for screen readers (Discord's image description)
const altText = (course, board, runs, legacy) => runs.length
  ? `${course.name} ${legacy ? "legacy top 10, before May 2026" : `top 10, board ${board}`}: ` + runs.map((r, i) => `${i + 1}. ${r.name} ${r.time}, ${r.mistakes} mistakes`).join("; ")
  : `${course.name} top 10: no times yet`;

/* ---------- Fonts and logo for the picture ---------- */
function fonts() {
  const file = (pkg, name) => {
    const p = path.join(HERE, "node_modules", pkg, "files", name);
    return fs.existsSync(p) ? pathToFileURL(p).href : "";
  };
  return {
    "Barlow-500-normal": file("@fontsource/barlow", "barlow-latin-500-normal.woff2"),
    "Barlow-600-normal": file("@fontsource/barlow", "barlow-latin-600-normal.woff2"),
    "Barlow-700-normal": file("@fontsource/barlow", "barlow-latin-700-normal.woff2"),
    "Barlow Condensed-800-italic": file("@fontsource/barlow-condensed", "barlow-condensed-latin-800-italic.woff2"),
    "JetBrains Mono-400-normal": file("@fontsource/jetbrains-mono", "jetbrains-mono-latin-400-normal.woff2"),
    "JetBrains Mono-600-normal": file("@fontsource/jetbrains-mono", "jetbrains-mono-latin-600-normal.woff2"),
    "JetBrains Mono-700-normal": file("@fontsource/jetbrains-mono", "jetbrains-mono-latin-700-normal.woff2"),
  };
}

/* ---------- Main ---------- */
const history = JSON.parse(fs.readFileSync(HISTORY, "utf8"));
const jobs = [];
for (const course of LEGACY ? COURSES : []) {
  // The legacy top 10 (history.json keeps every legacy run, so the website can show them all)
  const runs = history[course.n] && Array.isArray(history[course.n].legacy) ? history[course.n].legacy.slice(0, 10) : [];
  if (!runs.length || (FORCE && FORCE !== "all" && !FORCE.has(course.n))) continue;
  if (!course.legacyChannel) {
    console.warn(`${course.n} ${course.name} has a legacy board but no legacyChannel in courses.json, so it's skipped`);
    continue;
  }
  jobs.push({ course, list: [runs], at: 0, isNew: false, legacy: true, channel: course.legacyChannel });
}
// Each course's top 10: its file and the runs sent from the website, together (see ratings.mjs)
const boards = new Map(loadCourses().map((c) => [c.n, c]));
// Each player's rating over every course, shown on their rows (not on legacy boards, which don't count toward it)
const ratingOf = new Map(rate([...boards.values()]).players.map((p) => [p.key, p.rating]));
for (const course of LEGACY ? [] : COURSES) {
  const archived = (history[course.n] && Array.isArray(history[course.n].boards)) ? history[course.n].boards : [];
  const data = boards.get(course.n);
  const live = data.ok ? standings(data).top : null;
  if (FORCE) {
    if (FORCE !== "all" && !FORCE.has(course.n)) continue;
    // The newest posted board, or the live one if none was posted yet, or an empty board if there are no runs
    const list = archived.length ? archived : live && live.length ? [live] : [[]];
    jobs.push({ course, list, at: list.length - 1, isNew: false, channel: course.channel });
    continue;
  }
  if (!live || !live.length) continue;
  if (archived.length && sameBoard(live, archived[archived.length - 1])) continue;
  jobs.push({ course, list: [...archived, live], at: archived.length, isNew: true, channel: course.channel });
}
if (!jobs.length) {
  console.log(LEGACY ? "None of those courses have a legacy board to post."
    : FORCE ? "None of those course numbers exist." : "No leaderboard changed since the last posted board.");
  process.exit(FORCE || LEGACY ? 1 : 0);
}

fs.mkdirSync(OUT, { recursive: true });
const logo = await dataUri("https://ballkour.com/assets/logo.webp");
const fontUrls = fonts();
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1100, height: 900 }, deviceScaleFactor: 2 });
const channelTypes = new Map();
const archivedNow = [];
let failed = false;

for (const { course, list, at, isNew, legacy, channel } of jobs) {
  const runs = list[at];
  const board = runs.length && !legacy ? at + 1 : 0; // 0: no runs yet or a legacy board, so no board number
  const fresh = legacy ? new Set() : freshRuns(runs, at > 0 ? list[at - 1] : []);
  const label = legacy ? `${course.n} ${course.name}, legacy board`
    : board ? `${course.n} ${course.name}, board ${board}` : `${course.n} ${course.name}, no runs yet`;
  try {
    const people = new Map();
    for (const r of runs) {
      const who = DISCORD_ID.test(r.discord) ? await person(r.discord) : null;
      if (who) people.set(r, who);
    }
    const slug = path.basename(course.file).replace(/\.[^.]+$/, "").normalize("NFD").replace(/[^\w-]+/g, "");
    const base = legacy ? `${slug}-legacy` : board ? `${slug}-board-${board}` : `${slug}-empty`;
    const filename = `${base}.png`;
    const htmlFile = path.join(OUT, `${base}.html`);
    fs.writeFileSync(htmlFile, cardHtml({ course, board, date: boardDate(runs), runs, fresh: NOT_NEW ? new Set() : fresh, people, logo, fonts: fontUrls, legacy,
      ratings: legacy ? new Map() : new Map(runs.filter((r) => ratingOf.has(playerKey(r))).map((r) => [r, ratingOf.get(playerKey(r))])) }));
    await page.goto(pathToFileURL(htmlFile).href, { waitUntil: "load" });
    await page.evaluate(() => document.fonts.ready);
    const png = await page.locator(".card").screenshot({ path: path.join(OUT, filename) });
    const { content, users } = legacy ? legacyMessage() : runs.length ? message(course, runs, fresh) : emptyMessage(course);
    fs.writeFileSync(path.join(OUT, `${base}.txt`), content + "\n");
    console.log(`\n${label}\n${content}`);
    if (DRY) continue;

    const form = new FormData();
    form.append("payload_json", JSON.stringify({
      content,
      allowed_mentions: { parse: [], users }, // ping only the new runners
      attachments: [{ id: 0, filename, description: altText(course, board, runs, legacy).slice(0, 1024) }],
      flags: 4, // no link previews
    }));
    form.append("files[0]", new Blob([png], { type: "image/png" }), filename);
    const posted = await api("POST", `/channels/${channel}/messages`, form);
    console.log(`Posted ${label}`);

    // In an announcement channel, publish it so servers following the channel get it too
    if (!channelTypes.has(channel)) channelTypes.set(channel, (await api("GET", `/channels/${channel}`)).type);
    if (channelTypes.get(channel) === 5) {
      await api("POST", `/channels/${channel}/messages/${posted.id}/crosspost`).catch((e) => console.warn(`Couldn't publish ${label}: ${e.message}`));
    }

    if (isNew) {
      history[course.n] = history[course.n] || { course: course.name };
      history[course.n].boards = list;
      fs.writeFileSync(HISTORY, dumpHistory(history)); // saved after each post, so a later failure can't repost this one
      archivedNow.push(`- ${course.name}: board ${board}`);
    }
  } catch (e) {
    failed = true;
    console.error(`Failed on ${label}: ${e.message}`);
  }
}
await browser.close();

if (archivedNow.length) {
  fs.writeFileSync(path.join(OUT, "commit-message.txt"), `chore(leaderboard): archive posted boards\n\n${archivedNow.join("\n")}\n`);
}
if (failed) process.exit(1);

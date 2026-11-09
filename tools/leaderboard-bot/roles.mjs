// Gives every rated player on the Discord server one role for their place in the player ratings: Top 0.1%, Top 1%,
// Top 5%, Top 10%, Top 25%, Top 50%, Top 75% or Top 90%, the best one they reach, or Rated for the bottom 10%.
// Everyone else on the server (not bots) gets Unrated. Their other rating roles are taken away, so nobody has two.
// Only runs with a Discord ID count toward someone's role. The ratings are worked out in ratings.mjs.
//
// It also gives out Top 10 to anyone with a run on a course's top 10, and Former Top 10 once none of their runs is on
// one any more (see "Top 10 and Former Top 10" below), and Legacy Top 10 to anyone with a run on a course's legacy
// top 10, from before May 2026 (see "Legacy Top 10" below).
//
// Run by .github/workflows/leaderboard-bot.yml after the boards are posted, and once a day for people who joined the
// server since. Settings come from the environment:
//   DISCORD_BOT_TOKEN  the bot's token. Without it, the ratings are only printed.
//   DRY_RUN=1          print what would change, but don't create or give out any roles
//
// The roles are found by name, so keep the words of their names as they are. Emojis or symbols around them are fine
// ("🥇 Top 10%"), and so are their color and place in the list. Any that are missing are made, with no permissions. The bot needs Manage Roles, its own role has to be above the rating
// roles in Server Settings → Roles, and it needs the Server Members Intent (Developer Portal → Bot) to see who has a
// rating role now. Without the intent, it only checks the rated players, and nobody gets Unrated.
import { GUILD, ROLES, HISTORY, DISCORD_ID, loadCourses, readData } from "./boards.mjs";
import { TOKEN, api } from "./discord.mjs";
import { TIERS, roleName, rate, standings, sameRun } from "./ratings.mjs";

const DRY = !!process.env.DRY_RUN;

/* ---------- The ratings ---------- */
const courses = loadCourses();
// A course's file that can't be read would drop its runs from everyone's rating, so nothing changes until it's fixed
const unread = courses.filter((c) => !c.ok);
if (unread.length) {
  console.error(`Couldn't read ${unread.map((c) => c.course.file).join(", ")}, so no roles were changed.`);
  process.exit(1);
}
const { counted, players } = rate(courses);
console.log(`${players.length} rated players over ${counted.length} courses (${counted.join(", ")})`);
for (const p of players) {
  console.log(`  ${String(p.rank).padStart(3)}. ${p.name.padEnd(16)} ${Math.round(p.rating).toString().padStart(5)}  ${roleName(p.tier)}${p.discord ? "" : "  (no Discord ID)"}`);
}
if (!TOKEN) {
  console.log("\nNo DISCORD_BOT_TOKEN, so no roles were checked.");
  process.exit(0);
}

/* ---------- The roles ---------- */
const PERMISSIONS_HINT = "Ballkyrie needs the Manage Roles permission, and its own role has to be above the rating roles in Server Settings → Roles.";
const existing = await api("GET", `/guilds/${GUILD}/roles`);
const UNRATED = "unrated";
const label = (key) => (key === UNRATED ? "Unrated" : roleName(key));
const roleOf = new Map(); // tier (null for Rated, UNRATED for everyone else) → role ID
for (const tier of [...TIERS, null, UNRATED]) {
  const name = label(tier);
  // Its name without emojis or symbols around it: "🥇 Top 10%" is the Top 10% role
  const bare = (s) => s.replace(/^[^\p{L}\p{N}]+|(?<=%|[\p{L}\p{N}])[^\p{L}\p{N}%]+$/gu, "");
  const found = existing.find((r) => bare(r.name) === name);
  if (found) { roleOf.set(tier, found.id); continue; }
  if (DRY) { console.log(`Would make the ${name} role`); roleOf.set(tier, `new ${name}`); continue; }
  try {
    const made = await api("POST", `/guilds/${GUILD}/roles`, { name, permissions: "0", hoist: false, mentionable: false });
    roleOf.set(tier, made.id);
    console.log(`Made the ${name} role`);
  } catch (e) {
    console.error(`Couldn't make the ${name} role. ${PERMISSIONS_HINT}\n  ${e.message}`);
    process.exit(1);
  }
}
const topRoles = new Set(roleOf.values());
const tierOfRole = new Map([...roleOf].map(([tier, id]) => [id, tier]));

// The role each rated player with a Discord ID should have
const want = new Map();
for (const p of players) if (p.discord) want.set(p.discord, roleOf.get(p.tier));
const nameOf = new Map(players.filter((p) => p.discord).map((p) => [p.discord, p.name]));

/* Top 10 and Former Top 10: who's on a course's top 10 right now, and who has been on a posted board (history.json).
   Runs taken off for good (runs.json's "removed") count for neither. */
const onTop10 = new Set(), wasTop10 = new Set();
for (const c of courses) {
  for (const r of standings(c).top) if (r.discord) onTop10.add(r.discord);
  for (const r of c.boards.flat()) if (r.discord && !c.removed.some((x) => sameRun(x, r))) wasTop10.add(r.discord);
}

/* Legacy Top 10: who has a run on a course's legacy top 10 (history.json's "legacy", from before May 2026). It's the
   top 10 the website's legacy boards show: each player once, with their best run, fastest first (ties go to fewer
   mistakes). Only runs with a Discord ID count, and most legacy runs have none until their player claims them on
   ballkour.com and a moderator links them. */
const legacySeconds = (t) => t.replace(/\.--$/, "").split(":").reduce((sum, part) => sum * 60 + Number(part), 0);
const byLegacyTime = (a, b) => legacySeconds(a.time) - legacySeconds(b.time) || a.mistakes - b.mistakes;
const onLegacyTop10 = new Set();
for (const e of Object.values(JSON.parse(readData(HISTORY)))) {
  const best = new Map(); // player (their Discord ID, or else their name) → their fastest legacy run
  for (const r of e && Array.isArray(e.legacy) ? e.legacy : []) {
    if (!r || typeof r.name !== "string" || !/^(\d{1,2}:)?\d{1,2}:\d{2}(\.--)?$/.test(r.time) || !Number.isInteger(r.mistakes)) continue;
    const key = DISCORD_ID.test(r.discord) ? "d:" + r.discord : "n:" + r.name.trim().toUpperCase();
    if (!best.has(key) || byLegacyTime(r, best.get(key)) < 0) best.set(key, r);
  }
  for (const r of [...best.values()].sort(byLegacyTime).slice(0, 10)) if (DISCORD_ID.test(r.discord)) onLegacyTop10.add(r.discord);
}

// Who has which rating roles now: every member of the server, or, without the Server Members Intent, the rated players
async function everyMember() {
  const all = [];
  for (let after = "0"; ;) {
    const page = await api("GET", `/guilds/${GUILD}/members?limit=1000&after=${after}`);
    all.push(...page);
    if (page.length < 1000) return all;
    after = page[page.length - 1].user.id;
  }
}
let members, everyone = true;
try {
  members = await everyMember();
} catch (e) {
  everyone = false;
  console.warn(`Couldn't list the server's members, so only the rated players are checked, and nobody gets Unrated. Turn on the Server Members Intent to give Unrated to everyone else and take rating roles away from anyone who isn't rated any more.\n  ${e.message}`);
  members = [];
  for (const id of new Set([...nameOf.keys(), ...onTop10, ...wasTop10, ...onLegacyTop10])) {
    try {
      members.push(await api("GET", `/guilds/${GUILD}/members/${id}`));
    } catch (err) {
      if (err.status !== 404) throw err; // 404: not on the server, so no role to give
    }
  }
}

let changes = 0, failed = false;
const unrated = { gave: 0, took: 0 }; // counted, not listed: on the first run, that's most of the server
for (const m of members) {
  const id = m.user.id;
  const who = nameOf.get(id) || m.nick || m.user.global_name || m.user.username;
  // Rated players get their tier, and everyone else Unrated (bots get nothing)
  const target = want.get(id) || (everyone && !m.user.bot ? roleOf.get(UNRATED) : undefined);
  const has = m.roles.filter((r) => topRoles.has(r));
  // [method, role, what a dry run says, what a real run says]
  const steps = [
    ...has.filter((r) => r !== target).map((r) => ["DELETE", r, `take ${label(tierOfRole.get(r))} from`, `Took ${label(tierOfRole.get(r))} from`]),
    ...(target && !has.includes(target) ? [["PUT", target, `give ${label(tierOfRole.get(target))} to`, `Gave ${label(tierOfRole.get(target))} to`]] : []),
  ];
  for (const [method, role, plan, done] of steps) {
    changes++;
    const quiet = tierOfRole.get(role) === UNRATED;
    if (quiet) unrated[method === "PUT" ? "gave" : "took"]++;
    if (DRY) { if (!quiet) console.log(`Would ${plan} ${who}`); continue; }
    try {
      await api(method, `/guilds/${GUILD}/members/${id}/roles/${role}`);
      if (!quiet) console.log(`${done} ${who}`);
    } catch (e) {
      failed = true;
      console.error(`Couldn't change ${who}'s roles. ${PERMISSIONS_HINT}\n  ${e.message}`);
    }
  }
}
/* Top 10 for a run on a top 10 now, Former Top 10 once there's none. Former is only ever taken away from someone back
   on a top 10, so one given by hand stays. */
if (ROLES.top10 && ROLES.formerTop10) {
  for (const m of members) {
    if (m.user.bot) continue;
    const id = m.user.id;
    const who = nameOf.get(id) || m.nick || m.user.global_name || m.user.username;
    const now = onTop10.has(id);
    const was = wasTop10.has(id) || m.roles.includes(ROLES.top10);
    const steps = [];
    if (now && !m.roles.includes(ROLES.top10)) steps.push(["PUT", ROLES.top10, "give Top 10 to", "Gave Top 10 to"]);
    if (now && m.roles.includes(ROLES.formerTop10)) steps.push(["DELETE", ROLES.formerTop10, "take Former Top 10 from", "Took Former Top 10 from"]);
    if (!now && m.roles.includes(ROLES.top10)) steps.push(["DELETE", ROLES.top10, "take Top 10 from", "Took Top 10 from"]);
    if (!now && was && !m.roles.includes(ROLES.formerTop10)) steps.push(["PUT", ROLES.formerTop10, "give Former Top 10 to", "Gave Former Top 10 to"]);
    for (const [method, role, plan, done] of steps) {
      changes++;
      if (DRY) { console.log(`Would ${plan} ${who}`); continue; }
      try {
        await api(method, `/guilds/${GUILD}/members/${id}/roles/${role}`);
        console.log(`${done} ${who}`);
      } catch (e) {
        failed = true;
        console.error(`Couldn't change ${who}'s roles. Ballkyrie's own role has to be above Top 10 and Former Top 10 too.\n  ${e.message}`);
      }
    }
  }
}
/* Legacy Top 10 for a run on a legacy top 10. It's only ever given, never taken away, so one given by hand stays (and
   a link undone by hand means taking it away by hand too). */
if (ROLES.legacyTop10) {
  for (const m of members) {
    const id = m.user.id;
    if (m.user.bot || !onLegacyTop10.has(id) || m.roles.includes(ROLES.legacyTop10)) continue;
    const who = nameOf.get(id) || m.nick || m.user.global_name || m.user.username;
    changes++;
    if (DRY) { console.log(`Would give Legacy Top 10 to ${who}`); continue; }
    try {
      await api("PUT", `/guilds/${GUILD}/members/${id}/roles/${ROLES.legacyTop10}`);
      console.log(`Gave Legacy Top 10 to ${who}`);
    } catch (e) {
      failed = true;
      console.error(`Couldn't give ${who} Legacy Top 10. Ballkyrie's own role has to be above Legacy Top 10 too.\n  ${e.message}`);
    }
  }
}
if (unrated.gave) console.log(`${DRY ? "Would give" : "Gave"} Unrated to ${unrated.gave} member${unrated.gave === 1 ? "" : "s"}`);
if (unrated.took) console.log(`${DRY ? "Would take" : "Took"} Unrated from ${unrated.took} member${unrated.took === 1 ? "" : "s"} who got rated`);
console.log(changes ? `\n${DRY ? "Would make" : "Made"} ${changes} role change${changes === 1 ? "" : "s"}.` : "\nEveryone already has the right role.");
if (failed) process.exit(1);

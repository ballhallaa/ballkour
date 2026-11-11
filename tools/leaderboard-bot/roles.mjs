// Gives every rated player on the Discord server one role for their place in the player ratings: Top 0.1%, Top 1%,
// Top 5%, Top 10%, Top 25%, Top 50%, Top 75% or Top 90%, the best one they reach, or Rated for the bottom 10%, each
// with "(Unassisted)" after it: Top 0.1% (Unassisted) and so on. Everyone else on the server (not bots) gets
// Unrated (Unassisted). Their other rating roles are taken away, so nobody has two. Only runs with a Discord ID count
// toward someone's role. The ratings are worked out in ratings.mjs.
//
// The assisted boards (runs played in Assist Mode) have a rating of their own, with roles of their own, the same ones
// with "(Assisted)" after them: Top 0.1% (Assisted) to Top 90% (Assisted), Rated (Assisted), and Unrated (Assisted)
// for everyone else. Everyone has one of each set. And so do the legacy boards, from before May 2026: Top 0.1%
// (Legacy) to Top 90% (Legacy) and Rated (Legacy), only for the players on them (there's no Unrated (Legacy)).
//
// It also gives out Top 10 to anyone with a run on a course's top 10, and Former Top 10 once none of their runs is on
// one any more (see "Top 10 and Former Top 10" below), the same with Top 10 (Assisted) and Former Top 10 (Assisted)
// for the assisted boards, and Legacy Top 10 to anyone with a run on a course's legacy top 10, from before May 2026
// (see "Legacy Top 10" below). And the ratings heading, the empty role that heads the rating roles on a member's
// profile, to everyone with a rating role, Unrated (Unassisted) and Unrated (Assisted) included, which is every member
// (see "The ratings heading" below).
//
// Run by .github/workflows/leaderboard-bot.yml after the boards are posted, and once a day for people who joined the
// server since. Settings come from the environment:
//   DISCORD_BOT_TOKEN  the bot's token. Without it, the ratings are only printed.
//   DRY_RUN=1          print what would change, but don't create or give out any roles
//
// The rating roles and the assisted Top 10 roles are found by name, so keep the words of their names as they are.
// Emojis or symbols around them are fine ("🥇 Top 10%", "🥇 Top 10% (Assisted)"), and so are their color and place in
// the list. Any that are missing are made, with no permissions. Top 10, Former Top 10 and Legacy Top 10 are found by
// their IDs in courses.json instead, and so is the ratings heading. The bot needs Manage Roles, its own role has to be above the rating
// roles in Server Settings → Roles, and it needs the Server Members Intent (Developer Portal → Bot) to see who has a
// rating role now. Without the intent, it only checks the rated players, and nobody gets Unrated.
import { GUILD, ROLES, HISTORY, DISCORD_ID, loadCourses, readData } from "./boards.mjs";
import { TOKEN, api } from "./discord.mjs";
import { TIERS, UNASSISTED_SUFFIX, ASSISTED_SUFFIX, LEGACY_SUFFIX, roleName, rate, standings, sameRun } from "./ratings.mjs";

const DRY = !!process.env.DRY_RUN;

/* ---------- The ratings ---------- */
const courses = loadCourses();
// A course's file that can't be read would drop its runs from everyone's rating, so nothing changes until it's fixed
const unread = courses.filter((c) => !c.ok);
if (unread.length) {
  console.error(`Couldn't read ${unread.map((c) => c.course.file).join(", ")}, so no roles were changed.`);
  process.exit(1);
}
const assistedCourses = loadCourses({ assisted: true });
const legacyCourses = loadCourses({ legacy: true });
// The three ratings, each with its own set of roles (suffix: what's after their names): the regular (unassisted) one,
// the assisted one, and the Legacy one, which has no Unrated (unratedRole: false)
const ratings = [
  { suffix: UNASSISTED_SUFFIX, what: "", unratedRole: true, courses, ...rate(courses) },
  { suffix: ASSISTED_SUFFIX, what: "assisted ", unratedRole: true, courses: assistedCourses, ...rate(assistedCourses) },
  { suffix: LEGACY_SUFFIX, what: "legacy ", unratedRole: false, courses: legacyCourses, ...rate(legacyCourses) },
];
for (const { suffix, what, counted, players } of ratings) {
  console.log(`${what ? "\n" : ""}${players.length} ${what}rated players over ${counted.length} courses (${counted.join(", ")})`);
  for (const p of players) {
    console.log(`  ${String(p.rank).padStart(3)}. ${p.name.padEnd(16)} ${Math.round(p.rating).toString().padStart(5)}  ${roleName(p.tier, suffix)}${p.discord ? "" : "  (no Discord ID)"}`);
  }
}
if (!TOKEN) {
  console.log("\nNo DISCORD_BOT_TOKEN, so no roles were checked.");
  process.exit(0);
}

/* ---------- The roles ---------- */
const PERMISSIONS_HINT = "Ballkyrie needs the Manage Roles permission, and its own role has to be above the rating roles in Server Settings → Roles.";
const existing = await api("GET", `/guilds/${GUILD}/roles`);
// A role's name without emojis or symbols around it: "🥇 Top 10%" is the Top 10% role. A name is compared after the
// same is done to it, which also drops the closing ")" of "(Assisted)" from both.
const bare = (s) => s.replace(/^[^\p{L}\p{N}]+|(?<=%|[\p{L}\p{N}])[^\p{L}\p{N}%]+$/gu, "");
// The ID of the role with this name, which is made if there's none
async function roleNamed(name) {
  const found = existing.find((r) => bare(r.name) === bare(name));
  if (found) return found.id;
  if (DRY) { console.log(`Would make the ${name} role`); return `new ${name}`; }
  try {
    const made = await api("POST", `/guilds/${GUILD}/roles`, { name, permissions: "0", hoist: false, mentionable: false });
    console.log(`Made the ${name} role`);
    return made.id;
  } catch (e) {
    console.error(`Couldn't make the ${name} role. ${PERMISSIONS_HINT}\n  ${e.message}`);
    process.exit(1);
  }
}
const UNRATED = "unrated";
const label = (key, suffix) => (key === UNRATED ? "Unrated" + suffix : roleName(key, suffix));
for (const set of ratings) {
  set.roleOf = new Map(); // tier (null for Rated, UNRATED for everyone else) → role ID
  for (const tier of [...TIERS, null, ...(set.unratedRole ? [UNRATED] : [])]) set.roleOf.set(tier, await roleNamed(label(tier, set.suffix)));
  set.ids = new Set(set.roleOf.values());
  set.tierOfRole = new Map([...set.roleOf].map(([tier, id]) => [id, tier]));
  // The role each rated player with a Discord ID should have
  set.want = new Map();
  for (const p of set.players) if (p.discord) set.want.set(p.discord, set.roleOf.get(p.tier));
  set.unrated = { gave: 0, took: 0 }; // counted, not listed: on the first run, that's most of the server
}
const roleLabel = (set, role) => label(set.tierOfRole.get(role), set.suffix);
// Each player's name as on their newest run, from the regular rating first
const nameOf = new Map();
for (const { players } of ratings) for (const p of players) if (p.discord && !nameOf.has(p.discord)) nameOf.set(p.discord, p.name);

/* Top 10 and Former Top 10: who's on a course's top 10 right now, and who has been on a posted board (history.json).
   Runs taken off for good (runs.json's "removed") count for neither. The assisted boards' are Top 10 (Assisted) and
   Former Top 10 (Assisted), which are found by name like the rating roles. */
const top10Sets = [];
if (ROLES.top10 && ROLES.formerTop10) top10Sets.push({ name: "Top 10", top: ROLES.top10, former: ROLES.formerTop10, courses });
top10Sets.push({
  name: "Top 10" + ASSISTED_SUFFIX,
  top: await roleNamed("Top 10" + ASSISTED_SUFFIX),
  former: await roleNamed("Former Top 10" + ASSISTED_SUFFIX),
  courses: assistedCourses,
});
for (const set of top10Sets) {
  set.now = new Set();
  set.was = new Set();
  for (const c of set.courses) {
    for (const r of standings(c).top) if (r.discord) set.now.add(r.discord);
    for (const r of c.boards.flat()) if (r.discord && !c.removed.some((x) => sameRun(x, r))) set.was.add(r.discord);
  }
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
  for (const id of new Set([...nameOf.keys(), ...top10Sets.flatMap((s) => [...s.now, ...s.was]), ...onLegacyTop10])) {
    try {
      members.push(await api("GET", `/guilds/${GUILD}/members/${id}`));
    } catch (err) {
      if (err.status !== 404) throw err; // 404: not on the server, so no role to give
    }
  }
}

/* The ratings heading: an empty role whose name heads the rating roles on a member's profile (like "──── Ratings ────").
   Everyone with a rating role has it: a Top % or Rated role, unassisted, assisted, or legacy, or Unrated (Unassisted) or Unrated
   (Assisted), which everyone else gets, so that's every member but bots. Discord's onboarding can take it away when someone changes their Channels & Roles picks, so it's
   given back on the next run (after a board is posted, and once a day). It used to be ball-bot's sticky role rule,
   which only knew the regular rating roles. */
const heading = ROLES.ratingsHeading || "";
const headingName = (((heading && existing.find((r) => r.id === heading)) || {}).name || "the ratings heading").trim();
let changes = 0, failed = false;
for (const m of members) {
  const id = m.user.id;
  const who = nameOf.get(id) || m.nick || m.user.global_name || m.user.username;
  if (heading && !m.user.bot) {
    // A rating role from any set: their tier, or Unrated where the set has it (and the members could be listed)
    const hasRating = ratings.some((set) => set.want.has(id) || (set.unratedRole && everyone));
    const has = m.roles.includes(heading);
    if (hasRating !== has) {
      changes++;
      const [method, plan, done] = hasRating ? ["PUT", "give", "Gave"] : ["DELETE", "take", "Took"];
      const what = `${headingName} ${hasRating ? "to" : "from"} ${who}`;
      if (DRY) console.log(`Would ${plan} ${what}`);
      else {
        try {
          await api(method, `/guilds/${GUILD}/members/${id}/roles/${heading}`);
          console.log(`${done} ${what}`);
        } catch (e) {
          failed = true;
          console.error(`Couldn't change ${who}'s roles. Ballkyrie's own role has to be above ${headingName} too.\n  ${e.message}`);
        }
      }
    }
  }
  for (const set of ratings) {
    // Rated players get their tier, and everyone else Unrated, where the rating has it (bots get nothing)
    const target = set.want.get(id) || (set.unratedRole && everyone && !m.user.bot ? set.roleOf.get(UNRATED) : undefined);
    const has = m.roles.filter((r) => set.ids.has(r));
    // [method, role, what a dry run says, what a real run says]
    const steps = [
      ...has.filter((r) => r !== target).map((r) => ["DELETE", r, `take ${roleLabel(set, r)} from`, `Took ${roleLabel(set, r)} from`]),
      ...(target && !has.includes(target) ? [["PUT", target, `give ${roleLabel(set, target)} to`, `Gave ${roleLabel(set, target)} to`]] : []),
    ];
    for (const [method, role, plan, done] of steps) {
      changes++;
      const quiet = set.tierOfRole.get(role) === UNRATED;
      if (quiet) set.unrated[method === "PUT" ? "gave" : "took"]++;
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
}
/* Top 10 for a run on a top 10 now, Former Top 10 once there's none. Former is only ever taken away from someone back
   on a top 10, so one given by hand stays. The same for Top 10 (Assisted) and Former Top 10 (Assisted). */
for (const set of top10Sets) {
  const former = "Former " + set.name;
  for (const m of members) {
    if (m.user.bot) continue;
    const id = m.user.id;
    const who = nameOf.get(id) || m.nick || m.user.global_name || m.user.username;
    const now = set.now.has(id);
    const was = set.was.has(id) || m.roles.includes(set.top);
    const steps = [];
    if (now && !m.roles.includes(set.top)) steps.push(["PUT", set.top, `give ${set.name} to`, `Gave ${set.name} to`]);
    if (now && m.roles.includes(set.former)) steps.push(["DELETE", set.former, `take ${former} from`, `Took ${former} from`]);
    if (!now && m.roles.includes(set.top)) steps.push(["DELETE", set.top, `take ${set.name} from`, `Took ${set.name} from`]);
    if (!now && was && !m.roles.includes(set.former)) steps.push(["PUT", set.former, `give ${former} to`, `Gave ${former} to`]);
    for (const [method, role, plan, done] of steps) {
      changes++;
      if (DRY) { console.log(`Would ${plan} ${who}`); continue; }
      try {
        await api(method, `/guilds/${GUILD}/members/${id}/roles/${role}`);
        console.log(`${done} ${who}`);
      } catch (e) {
        failed = true;
        console.error(`Couldn't change ${who}'s roles. Ballkyrie's own role has to be above ${set.name} and ${former} too.\n  ${e.message}`);
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
for (const set of ratings) {
  const name = label(UNRATED, set.suffix);
  const { gave, took } = set.unrated;
  if (gave) console.log(`${DRY ? "Would give" : "Gave"} ${name} to ${gave} member${gave === 1 ? "" : "s"}`);
  if (took) console.log(`${DRY ? "Would take" : "Took"} ${name} from ${took} member${took === 1 ? "" : "s"} who got rated`);
}
console.log(changes ? `\n${DRY ? "Would make" : "Made"} ${changes} role change${changes === 1 ? "" : "s"}.` : "\nEveryone already has the right role.");
if (failed) process.exit(1);

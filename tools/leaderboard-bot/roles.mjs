// Gives every rated player on the Discord server one role for their place in the player ratings: Top 0.1%, Top 1%,
// Top 5%, Top 10%, Top 25%, Top 50%, Top 75% or Top 90%, the best one they reach, or Rated for the bottom 10%. Their
// other rating roles are taken away, so nobody has two. Only runs with a Discord ID count toward someone's role. The
// ratings are worked out in ratings.mjs.
//
// Run by .github/workflows/leaderboard-bot.yml after the boards are posted, and once a day for people who joined the
// server since. Settings come from the environment:
//   DISCORD_BOT_TOKEN  the bot's token. Without it, the ratings are only printed.
//   DRY_RUN=1          print what would change, but don't create or give out any roles
//
// The roles are found by name, so keep the words of their names as they are. Emojis or symbols around them are fine
// ("🥇 Top 10%"), and so are their color and place in the list. Any that are missing are made, with no permissions. The bot needs Manage Roles, its own role has to be above the rating
// roles in Server Settings → Roles, and it needs the Server Members Intent (Developer Portal → Bot) to see who has a
// rating role now. Without the intent, it only checks the rated players.
import { GUILD, loadCourses } from "./boards.mjs";
import { TOKEN, api } from "./discord.mjs";
import { TIERS, roleName, rate } from "./ratings.mjs";

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
const roleOf = new Map(); // tier (null for Rated) → role ID
for (const tier of [...TIERS, null]) {
  const name = roleName(tier);
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
let members;
try {
  members = await everyMember();
} catch (e) {
  console.warn(`Couldn't list the server's members, so only the rated players are checked. Turn on the Server Members Intent to also take rating roles away from anyone who isn't rated any more.\n  ${e.message}`);
  members = [];
  for (const id of nameOf.keys()) {
    try {
      members.push(await api("GET", `/guilds/${GUILD}/members/${id}`));
    } catch (err) {
      if (err.status !== 404) throw err; // 404: not on the server, so no role to give
    }
  }
}

let changes = 0, failed = false;
for (const m of members) {
  const id = m.user.id;
  const who = nameOf.get(id) || m.nick || m.user.global_name || m.user.username;
  const target = want.get(id);
  const has = m.roles.filter((r) => topRoles.has(r));
  // [method, role, what a dry run says, what a real run says]
  const steps = [
    ...has.filter((r) => r !== target).map((r) => ["DELETE", r, `take ${roleName(tierOfRole.get(r))} from`, `Took ${roleName(tierOfRole.get(r))} from`]),
    ...(target && !has.includes(target) ? [["PUT", target, `give ${roleName(tierOfRole.get(target))} to`, `Gave ${roleName(tierOfRole.get(target))} to`]] : []),
  ];
  for (const [method, role, plan, done] of steps) {
    changes++;
    if (DRY) { console.log(`Would ${plan} ${who}`); continue; }
    try {
      await api(method, `/guilds/${GUILD}/members/${id}/roles/${role}`);
      console.log(`${done} ${who}`);
    } catch (e) {
      failed = true;
      console.error(`Couldn't change ${who}'s roles. ${PERMISSIONS_HINT}\n  ${e.message}`);
    }
  }
}
console.log(changes ? `\n${DRY ? "Would make" : "Made"} ${changes} role change${changes === 1 ? "" : "s"}.` : "\nEveryone already has the right role.");
if (failed) process.exit(1);

// The daily to-do: Ballkyrie sends TODO_USER a DM listing the in-game boards that are behind their course's board
// (game-boards.mjs), with the course and which board (Unassisted or Assisted), so they're updated before the next
// release. Nothing is sent when every in-game board is up to date, and only one is sent a day (UTC): the daily run's
// backup schedule doesn't send a second. leaderboard-bot.yml runs it on the daily run only.
//   node todo.mjs                prints the message, and sends it with DISCORD_BOT_TOKEN set (unless DRY_RUN=1)
import { behindBoards } from "./game-boards.mjs";
import { TOKEN, api } from "./discord.mjs";

// Who gets the DM: ballhallaa
const TODO_USER = "175372497720573953";
const LIMIT = 2000; // Discord's limit on a message's length

const behind = behindBoards();
if (!behind.length) {
  console.log("Every in-game board is up to date, so there's no to-do to send.");
  process.exit(0);
}

// One line per course, with its boards that are behind
const byCourse = new Map();
for (const { course, board } of behind) {
  if (!byCourse.has(course.n)) byCourse.set(course.n, { course, modes: [] });
  byCourse.get(course.n).modes.push(board === "lb" ? "Unassisted" : "Assisted");
}
const courses = [...byCourse.values()];
const TITLE = "**In-game leaderboards to update**";
const head = `${TITLE} (${behind.length} board${behind.length === 1 ? "" : "s"} on ${courses.length} course${courses.length === 1 ? "" : "s"}):`;
const foot = "Run `node tools/leaderboard-bot/game-boards.mjs` for the lines to paste.";
// "1 🇬🇮 Watchpoint: Gibraltar", with the course's flag from courses.json
const lines = courses.map(({ course, modes }) => `- **${course.n} ${course.flag || "•"} ${course.name}**: ${modes.join(" and ")}`);
let message = [head, ...lines, "", foot].join("\n");
// Cut down to Discord's limit (far more courses than there are), saying how many are left out
for (let keep = lines.length - 1; message.length > LIMIT && keep > 0; keep--) {
  message = [head, ...lines.slice(0, keep), `- …and ${lines.length - keep} more`, "", foot].join("\n");
}
console.log(message);

if (process.env.DRY_RUN || !TOKEN) {
  console.log(TOKEN ? "\nDry run: not sent." : "\nNo DISCORD_BOT_TOKEN: not sent.");
  process.exit(0);
}
const dm = await api("POST", "/users/@me/channels", { recipient_id: TODO_USER });
const me = await api("GET", "/users/@me");
const today = new Date().toISOString().slice(0, 10);
// Ballkyrie's other DMs (a moderator checked their run, …) don't count
const recent = await api("GET", `/channels/${dm.id}/messages?limit=20`);
if (recent.some((m) => m.author.id === me.id && m.content.startsWith(TITLE) && m.timestamp.slice(0, 10) === today)) {
  console.log(`\nAlready sent today (${today}): not sent again.`);
  process.exit(0);
}
await api("POST", `/channels/${dm.id}/messages`, { content: message, allowed_mentions: { parse: [] } });
console.log(`\nSent to ${TODO_USER}.`);

// The boards, the player ratings, and the Top X% tier each player reaches. The website works out the same boards and
// ratings (index.html in ballhallaa/ballkour.com, under "Every run, and the ratings"): keep the two in step.
//
// A course's board ranks every run in its file and in runs.json (the runs sent from the website, and runs that never
// made a top 10), once each per player with their best run, minus the runs taken off for good (runs.json's "removed").
// Its top 10 is what's posted on Discord. Below it come the players who dropped out of the top 10, from the boards in
// history.json, but only with runs slower than today's #10: a faster one that isn't on the board any more was taken
// off it (or the board was cleared), not pushed off.
//
// Every course is worth up to 1,000 points: 1000 × ln(1 + (e − 1) × record ÷ time)². The record gets all of them,
// and it's lucio.surf's curve for a player who has run every map, at a tenth of its 10,000 (it was 10,000 here too
// until November 2026). A rating is the average over every course that isn't
// broken, with 0 for the ones a player hasn't run (and for courses nobody has run yet), so a new or faster run never
// lowers it, and the first run on a course changes nobody else's rating. A player's tier is their place divided by the number of rated players: #4 of 40 is in the Top 10%.
// Everyone past the last tier (the bottom 10%) is just Rated.

export const TIERS = [0.1, 1, 5, 10, 25, 50, 75, 90];
// The Discord role for a tier: "Top 10%", or "Rated" for the bottom 10% (tier null)
export const roleName = (tier) => (tier === null ? "Rated" : `Top ${tier}%`);

const seconds = (t) => t.split(":").reduce((sum, part) => sum * 60 + Number(part), 0);
const byTime = (a, b) => seconds(a.time) - seconds(b.time) || a.mistakes - b.mistakes;

// A player is their Discord ID, or for a run without one, its in-game name. In-game names aren't unique (Overwatch
// hides the BattleTag number), so a name only stands for a player on runs with no ID.
export const playerKey = (r) => (r.discord ? "d:" + r.discord : "n:" + r.name.toUpperCase());
// The same run: same time, and the same player (their Discord ID when both have one, and their name otherwise)
export const sameRun = (a, b) => a.time === b.time && (a.discord && b.discord ? a.discord === b.discord : a.name.toUpperCase() === b.name.toUpperCase());
// One run per player, their fastest, fastest first. Ties keep the order the runs came in.
function bestEach(runs) {
  const best = new Map();
  for (const r of runs) {
    const key = playerKey(r);
    const had = best.get(key);
    if (!had || byTime(r, had) < 0) best.set(key, r);
  }
  return [...best.values()].sort(byTime);
}

// course: { file: [run, …], more: [run, …], removed: [run, …], boards: [[run, …], …] } → { top: [run, …], rest: [run, …] }
export function standings(course) {
  const kept = (r) => !course.removed.some((x) => sameRun(x, r));
  const live = [...course.file, ...course.more].filter(kept);
  const board = bestEach(live);
  const last = board.length >= 10 ? board[9] : null;
  const old = last ? course.boards.flat().filter((r) => kept(r) && byTime(r, last) >= 0) : [];
  const all = bestEach([...live, ...old]);
  return { top: all.slice(0, 10), rest: all.slice(10) };
}

// courses: [{ n, broken, file, more, removed, boards }] as standings() takes them, runs { name, discord, time,
// mistakes, date } with dates as YYYY-MM-DD
// → { counted: [course numbers], players: [{ key, name, discord, rating, points: { n: points }, courses, rank, tier }] }
export function rate(courses) {
  const counted = [];
  const players = new Map();
  for (const c of courses) {
    if (c.broken) continue;
    counted.push(c.n);
    const { top, rest } = standings(c);
    const all = [...top, ...rest];
    if (!all.length) continue; // nobody has run it yet: 0 for everyone
    const record = seconds(all[0].time);
    for (const r of all) {
      const key = playerKey(r);
      if (!players.has(key)) players.set(key, { key, name: r.name, discord: r.discord || "", date: "", points: {} });
      const p = players.get(key);
      // Named as on their newest run
      if ((r.date || "") > p.date) { p.date = r.date; p.name = r.name; }
      p.points[c.n] = 1000 * Math.log(1 + (Math.E - 1) * record / seconds(r.time)) ** 2;
    }
  }
  const list = [...players.values()].map((p) => {
    const pts = Object.values(p.points);
    return { ...p, courses: pts.length, rating: pts.reduce((a, b) => a + b, 0) / (counted.length || 1) };
  });
  list.sort((a, b) => b.rating - a.rating || b.courses - a.courses || (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));
  // Players with the same rating share the better place
  const same = (a, b) => Math.round(a.rating * 100) === Math.round(b.rating * 100);
  list.forEach((p, i) => {
    p.rank = i > 0 && same(list[i - 1], p) ? list[i - 1].rank : i + 1;
    p.tier = TIERS.find((tier) => (p.rank / list.length) * 100 <= tier + 1e-9) ?? null;
  });
  return { counted, players: list };
}

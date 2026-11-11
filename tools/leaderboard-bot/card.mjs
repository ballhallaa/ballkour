// The leaderboard picture: a course's top 10 in two columns, in the website's look.
// bot.mjs fills it in and screenshots the .card element.

const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

const BOLT = '<svg class="i" viewBox="0 0 24 24"><path fill="currentColor" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round" d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/></svg>';
const STAR = '<svg class="i" viewBox="0 0 24 24"><path fill="currentColor" stroke="currentColor" stroke-width="1.2" stroke-linejoin="round" d="M11.53 2.3a.53.53 0 0 1 .94 0l2.31 4.68a2.12 2.12 0 0 0 1.6 1.16l5.16.75a.53.53 0 0 1 .3.91l-3.74 3.64a2.12 2.12 0 0 0-.61 1.88l.88 5.14a.53.53 0 0 1-.77.56l-4.62-2.43a2.12 2.12 0 0 0-1.97 0L6.4 21.01a.53.53 0 0 1-.77-.56l.88-5.14a2.12 2.12 0 0 0-.61-1.88L2.16 9.8a.53.53 0 0 1 .3-.91l5.16-.75a2.12 2.12 0 0 0 1.6-1.16z"/></svg>';
const SKULL = '<svg class="i" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12.5 17-.5-1-.5 1h1z"/><path d="M15 22a1 1 0 0 0 1-1v-1a2 2 0 0 0 1.56-3.25 8 8 0 1 0-11.12 0A2 2 0 0 0 8 20v1a1 1 0 0 0 1 1z"/><circle cx="15" cy="12" r="1"/><circle cx="9" cy="12" r="1"/></g></svg>';

// fonts: { "Barlow-500": "file://…woff2", … }; missing files fall back to the stacks below
function fontFaces(fonts) {
  const faces = [
    ["Barlow", 500, "normal"], ["Barlow", 600, "normal"], ["Barlow", 700, "normal"],
    ["Barlow Condensed", 800, "italic"],
    ["JetBrains Mono", 400, "normal"], ["JetBrains Mono", 600, "normal"], ["JetBrains Mono", 700, "normal"],
  ];
  return faces
    .map(([family, weight, style]) => {
      const url = fonts[`${family}-${weight}-${style}`];
      return url ? `@font-face { font-family: "${family}"; font-weight: ${weight}; font-style: ${style}; src: url("${url}") format("woff2"); }` : "";
    })
    .join("\n");
}

/**
 * course: { name, flag, code, by, remaker, legacyCode } from courses.json, board: board number, date: "YYYY-MM-DD",
 * runs: [{ name, time, mistakes, date }] (up to 10), fresh: Set of the runs that are new,
 * people: Map of run → { name, avatar } from Discord, ratings: Map of run → its player's rating over every course,
 * logo: data URI or "",
 * legacy: true for the board from before May 2026, whose times have no hundredths ("4:30.--"),
 * assisted: true for a course's assisted board (runs played in Assist Mode), whose ratings are the assisted rating
 */
export function cardHtml({ course, board, date, runs, fresh, people, ratings = new Map(), logo, fonts, legacy = false, assisted = false }) {
  // A legacy time's missing hundredths are dimmed, as on the website
  const timeHtml = (t) => {
    const m = /^(.*?)(\.--)$/.exec(t);
    return m ? `<span>${esc(m[1])}<span class="na">.--</span></span>` : esc(t); // one span, so the gap stays by the icon
  };
  const row = (r, i) => {
    if (!r) {
      return `<li class="run empty"><span class="rank">${i + 1}</span><span class="line"><span class="name">---</span></span>` +
        `<span class="time">${BOLT}-:--.--</span><span class="miss"></span></li>`;
    }
    const isNew = fresh.has(r);
    const who = people.get(r);
    const pfp = who && who.avatar ? `<img class="pfp" src="${who.avatar}" alt="">` : "";
    return `<li class="run${i < 3 ? " p" + (i + 1) : ""}${isNew ? " fresh" : ""}">` +
      `<span class="rank">${i + 1}</span>` +
      `<span class="line"><span class="name">${esc(r.name)}</span>${isNew ? '<span class="tag">New</span>' : ""}</span>` +
      `<span class="time">${BOLT}${timeHtml(r.time)}</span>` +
      `<span class="miss">${SKULL}${r.mistakes}</span>` +
      (who ? `<span class="dc">${pfp}<span>${esc(who.name)}</span></span>` : "") +
      // Beside the date: the player's rating over every course, as on the website's Player ratings (no thousands
      // separator, like there: a rating only reaches 1000)
      `<span class="date">${ratings.has(r) ? `<span class="pts">${STAR}${Math.round(ratings.get(r))}</span>` : ""}${esc(r.date || "")}</span>` +
      `</li>`;
  };
  const slots = Array.from({ length: 10 }, (_, i) => runs[i] || null);
  // Two lines under the title: which board this is, then the course's code and who made it. A broken code is shown
  // like any other. A legacy board was set on the original course, so it shows that course's code (legacyCode) and
  // no remaker.
  const line = (parts) => parts.filter(Boolean).map((s) => `<span>${s}</span>`).join("<span>·</span>");
  const field = (label, value) => (value ? `${label} <b>${esc(value)}</b>` : "");
  const sub = legacy ? line(["Legacy top 10", "Before May 2026"])
    : line([assisted ? "Assisted top 10" : "Top 10", date, board ? `Board ${board}` : ""]);
  const credits = line([field("Code", legacy ? course.legacyCode : course.code), field("Creator", course.by),
    legacy ? "" : field("Remaker", course.remaker)]);

  return `<!doctype html><meta charset="utf-8"><style>
${fontFaces(fonts)}
:root {
  --void: #030605; --ink: #ecf6f2; --ink-2: #a7b6b0; --ink-3: #76867f; --line: rgba(196,255,232,.11);
  --volt: #00e697; --coral: #ff6a4f; --gold: #ffd54f; --silver: #d3dde2; --bronze: #e8a066; --discord: #b9befc; --pink: #ff80c0;
  --display: "Barlow Condensed", "TeX Gyre Heros Cn", "Arial Narrow", sans-serif;
  --body: "Barlow", "Inter", "Noto Sans", sans-serif;
  --mono: "JetBrains Mono", "DejaVu Sans Mono", monospace;
  --cjk: "Noto Sans CJK SC", "Noto Sans CJK JP";
  --emoji: "Noto Color Emoji";
}
* { box-sizing: border-box; }
body { margin: 0; background: var(--void); }
.card { position: relative; width: 1040px; padding: 34px 36px 26px; overflow: hidden; background: var(--void); color: var(--ink); font-family: var(--body), var(--cjk); }
#warp { position: absolute; inset: 0; width: 100%; height: 100%; }
.card > :not(canvas) { position: relative; }
.head { display: flex; align-items: center; justify-content: space-between; gap: 24px; margin-bottom: 22px; }
.title { margin: 0; display: flex; align-items: center; gap: 16px; font: italic 800 54px/0.9 var(--display), var(--cjk); text-transform: uppercase; letter-spacing: .005em;
  text-shadow: .035em 0 0 rgba(255,154,46,.8), -.035em 0 0 rgba(51,198,255,.75), 0 0 .45em rgba(0,230,151,.3); }
.flag { font: 400 40px/1 var(--emoji); text-shadow: none; }
/* After an assisted board's course name: its runs were played in Assist Mode, in the game's own pink for it. A
   remake's regular board, which has an assisted one beside it, gets an orange Unassisted one, the game's orange. */
.mode { flex: none; padding: 8px 12px 7px; border-radius: 8px; font: normal 700 17px/1 var(--mono); letter-spacing: .14em; color: var(--pink);
  background: rgba(255,128,192,.12); border: 1px solid rgba(255,128,192,.5); text-shadow: none; }
.mode.unassisted { color: #e69700; background: rgba(230,151,0,.12); border-color: rgba(230,151,0,.5); }
.sub { margin-top: 12px; display: flex; gap: 10px; font: 600 15px/1 var(--mono); letter-spacing: .12em; text-transform: uppercase; color: var(--ink-3); }
.sub b { color: var(--ink-2); font-weight: 600; }
.sub + .sub { margin-top: 9px; }
.logo { position: relative; width: 104px; height: 104px; flex: none; }
.logo::before { content: ""; position: absolute; inset: -12%; border-radius: 50%; background: conic-gradient(#ff4b3e, #ff9a2e, #ffd23f, #00e697, #33c6ff, #5a6bff, #a54bd8, #ff4b3e); filter: blur(18px); opacity: .5; }
.logo img { position: relative; width: 100%; height: 100%; }
.cols { display: grid; grid-template-columns: 1fr 1fr; gap: 0 22px; }
ol { list-style: none; margin: 0; padding: 0; display: grid; gap: 4px; }
.run { display: grid; grid-template-columns: 34px minmax(0, 1fr) auto 66px; grid-template-areas: "rank name time miss" "rank dc date date"; align-items: center; align-content: center; gap: 7px 12px;
  height: 74px; padding: 0 16px; border-radius: 11px; background: rgba(9,15,13,.93); border: 1px solid var(--line); font-variant-numeric: tabular-nums; }
.rank { grid-area: rank; font: 700 22px/1 var(--mono); color: var(--ink-3); }
.line { grid-area: name; min-width: 0; display: flex; align-items: center; gap: 9px; }
.name { min-width: 0; white-space: nowrap; overflow: hidden; font: 700 25px/1.1 var(--body), var(--cjk); letter-spacing: .03em; text-transform: uppercase; color: var(--ink); }
.date { grid-area: date; justify-self: end; display: inline-flex; align-items: center; gap: 14px; font: 400 13.5px/1 var(--mono); color: var(--ink-3); }
.pts { display: inline-flex; align-items: center; gap: 5px; color: var(--ink-2); }
.pts .i { width: 15px; height: 15px; color: var(--gold); }
.time { grid-area: time; }
.miss { grid-area: miss; }
.time, .miss { display: inline-flex; align-items: center; justify-content: flex-end; gap: 7px; font: 700 23px/1 var(--mono); color: var(--ink); }
.miss { font-size: 20px; color: var(--ink-2); }
.i { width: 21px; height: 21px; flex: none; }
.time .i { color: var(--volt); }
.miss .i { width: 19px; height: 19px; color: var(--coral); }
.dc { grid-area: dc; min-width: 0; display: flex; align-items: center; gap: 7px; font: 600 16px/1.1 var(--body), var(--cjk); color: var(--discord); }
.dc > span { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.pfp { width: 22px; height: 22px; flex: none; border-radius: 50%; object-fit: cover; }
.run.p1, .run.p2, .run.p3 { --tier: var(--gold); background: linear-gradient(90deg, color-mix(in srgb, var(--tier) 17%, rgba(9,15,13,.95)), rgba(9,15,13,.93) 70%); border-color: color-mix(in srgb, var(--tier) 30%, transparent); }
.run.p2 { --tier: var(--silver); } .run.p3 { --tier: var(--bronze); }
.run.p1 .rank, .run.p1 .name, .run.p2 .rank, .run.p2 .name, .run.p3 .rank, .run.p3 .name { color: var(--tier); }
.run.fresh { border-color: rgba(0,230,151,.55); box-shadow: inset 3px 0 0 var(--volt), 0 0 22px -6px rgba(0,230,151,.45); }
.time .na { color: var(--ink-3); }
.run.empty { opacity: .38; }
.run.empty .name, .run.empty .time { color: var(--ink-3); }
.tag { flex: none; padding: 3px 6px; border-radius: 5px; font: 700 11px/1 var(--mono); letter-spacing: .1em; text-transform: uppercase; color: var(--volt); background: rgba(0,230,151,.12); border: 1px solid rgba(0,230,151,.4); }
/* Course number on the left, the board's link in the middle (centered on the card), the note on the right.
   The labels match the lines under the title. A legacy board notes that videos weren't required for its runs; the
   note is kept short so it fits on one line in caps beside the longer /legacy link. An empty board invites the first time in volt instead, or, when the course is broken and no times can be set,
   says so in coral. */
.foot { margin-top: 18px; display: grid; grid-template-columns: 1fr auto 1fr; align-items: baseline; gap: 20px; font: 600 13px/1.3 var(--mono); letter-spacing: .12em; text-transform: uppercase; color: var(--ink-3); }
.foot b { color: var(--ink-2); font-weight: 600; }
.foot .url { font-size: 14px; color: var(--ink-2); letter-spacing: .02em; text-transform: none; }
.foot .note { text-align: right; }
.foot .cta { color: var(--volt); }
.foot .broken { color: var(--coral); }
</style>
<div class="card">
  <canvas id="warp"></canvas>
  <div class="head">
    <div>
      <h1 class="title"><span class="flag">${course.flag || ""}</span>${esc(course.name)}${assisted ? `<span class="mode">Assisted</span>` : !legacy && course.remaker ? `<span class="mode unassisted">Unassisted</span>` : ""}</h1>
      <div class="sub">${sub}</div>
      ${credits ? `<div class="sub">${credits}</div>` : ""}
    </div>
    ${logo ? `<div class="logo"><img src="${logo}" alt=""></div>` : ""}
  </div>
  <div class="cols">
    <ol>${slots.slice(0, 5).map((r, i) => row(r, i)).join("")}</ol>
    <ol>${slots.slice(5, 10).map((r, i) => row(r, i + 5)).join("")}</ol>
  </div>
  <div class="foot"><span>Course <b>${course.n}</b></span><span class="url">ballkour.com/leaderboards/${course.n}${legacy ? "/legacy" : assisted ? "/assisted" : ""}</span>` +
    (legacy ? `<span class="note">Videos weren’t required</span>`
      : runs.length ? `<span class="note">Dates: <b>YYYY-MM-DD (UTC)</b></span>`
      : course.broken ? `<span class="note broken">Broken</span>`
      : `<span class="note cta">Be the first to set a time</span>`) + `</div>
</div>
<script>
// Names too long for their row shrink to fit instead of being cut off
document.querySelectorAll(".name").forEach((el) => {
  let size = 25;
  while (el.scrollWidth > el.clientWidth && size > 16) el.style.fontSize = (size -= 0.5) + "px";
});
// A still frame of the site's warp field, bursting from behind the logo (or the top right corner)
const cv = document.getElementById("warp"), card = cv.parentElement;
const W = card.offsetWidth, H = card.offsetHeight, dpr = 2;
cv.width = W * dpr; cv.height = H * dpr;
const ctx = cv.getContext("2d"); ctx.scale(dpr, dpr);
const lg = document.querySelector(".logo"), cr = card.getBoundingClientRect();
const lr = lg ? lg.getBoundingClientRect() : { left: cr.right - 140, top: cr.top + 30, width: 104, height: 104 };
const ox = lr.left - cr.left + lr.width / 2, oy = lr.top - cr.top + lr.height / 2;
const glow = ctx.createRadialGradient(ox, oy, 0, ox, oy, W * 0.8);
glow.addColorStop(0, "rgba(0,230,151,0.22)"); glow.addColorStop(0.3, "rgba(0,150,100,0.07)"); glow.addColorStop(1, "rgba(4,6,4,0)");
ctx.fillStyle = glow; ctx.fillRect(0, 0, W, H);
let seed = 7; const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);
const PAL = [[0,230,151],[0,230,151],[0,230,151],[110,255,205],[255,154,46],[51,198,255]];
ctx.globalCompositeOperation = "lighter"; ctx.lineCap = "round";
for (let i = 0; i < 150; i++) {
  const a = rnd() * Math.PI * 2, d = 70 + rnd() * Math.hypot(W, H), len = (0.12 + rnd() * 0.2) * d + 4, c = PAL[(rnd() * PAL.length) | 0];
  const cx = Math.cos(a), cy = Math.sin(a), al = Math.min(1, d / 260) * 0.34;
  ctx.lineWidth = (0.6 + rnd() * 1.5) * (0.55 + d / 700);
  ctx.strokeStyle = "rgba(" + c + "," + al.toFixed(3) + ")";
  ctx.beginPath(); ctx.moveTo(ox + cx * (d - len), oy + cy * (d - len)); ctx.lineTo(ox + cx * d, oy + cy * d); ctx.stroke();
}
ctx.globalCompositeOperation = "source-over";
const vig = ctx.createRadialGradient(W / 2, H / 2, Math.min(W, H) * 0.3, W / 2, H / 2, Math.max(W, H) * 0.75);
vig.addColorStop(0, "rgba(0,0,0,0)"); vig.addColorStop(1, "rgba(0,0,0,0.55)");
ctx.fillStyle = vig; ctx.fillRect(0, 0, W, H);
</script>`;
}

// A run's picture for its post on Discord (and the DM to its player once it's checked): its stats in the website's look,
// like the result the site shows after a run (statRowsHtml in index.html on ballkour.com). run-picture.mjs fills it in
// and screenshots the .card element.

const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

// fonts: { "Barlow-500-normal": "file://…woff2", … }, as bot.mjs makes them; missing files fall back to the stacks below
function fontFaces(fonts) {
  return Object.entries(fonts || {})
    .filter(([, url]) => url)
    .map(([key, url]) => {
      const [family, weight, style] = key.split("-");
      return `@font-face { font-family: "${family}"; font-weight: ${weight}; font-style: ${style}; src: url("${url}") format("woff2"); }`;
    })
    .join("\n");
}

/**
 * picture: from the Worker (runBlocks' picture() in cloudflare/worker.js on ballkour.com):
 *   { sections: [{ heading, rows: [{ label, value, from?, chip?: { text, tone }, note? }] }], tone,
 *     run?: { name, course, assisted, date }, status?: { text, tone } }
 * run: whose run it is, on which course, and when, under the wordmark; status: where a top-10 run stands with the
 * moderators, at its right ("held", "approved" or "down").
 * tone is "held" (waiting for a check: yellow), "down" (turned down: red), or "up"/"approved" (green), as the post's
 * colour. A chip's tone is "up" (mint), "down" (coral), "new" (blue), or "same" (grey ▲ 0).
 * columns: how many sections side by side (the first two, then the next two under them, …).
 * width: the card's width in CSS pixels (the picture is twice that, at deviceScaleFactor 2).
 * logo: the logo as a data URI (as bot.mjs gets it), or "" for the wordmark alone.
 */
// The line with whose run it is (see runCardHtml)
function runLine({ run, status }) {
  if (!run && !status) return "";
  const dot = '<span class="dot">·</span>';
  const parts = run ? [`<span class="who">${esc(run.name)}</span>`, `<span class="course">${esc(run.course)}</span>`,
    run.assisted && '<span class="mode">Assisted</span>', run.date && `<span>${esc(run.date)}</span>`].filter(Boolean) : [];
  return `<div class="runline"><div class="runinfo">${parts.join(dot).replace(`${dot}<span class="mode">`, '<span class="mode">')}</div>` +
    `${status ? `<span class="status ${esc(status.tone)}">${esc(status.text)}</span>` : ""}</div>`;
}
export function runCardHtml({ picture, fonts, logo = "", columns = 2, width = 680 }) {
  const chip = (c) => (c ? `<span class="chip ${esc(c.tone)}">${esc(c.text)}</span>` : "<span></span>");
  const row = (r) => `<div class="row"><span class="label">${esc(r.label)}</span>` +
    `<span class="value">${r.from !== undefined ? `<span class="was">${esc(r.from)} →</span> ` : ""}${esc(r.value)}</span>${chip(r.chip)}` +
    `${r.note ? `<span class="note">${esc(r.note)}</span>` : ""}</div>`;
  const section = (s) => `<section><h2>${esc(s.heading)}</h2>${s.rows.map(row).join("")}</section>`;
  return `<!doctype html>
<html><head><meta charset="utf-8"><style>
${fontFaces(fonts)}
:root {
  --line: rgba(196, 255, 232, 0.11); --ink: #ecf6f2; --ink-2: #a7b6b0; --ink-3: #76867f;
  --volt: #00e697; --arc: #33c6ff; --coral: #ff6a4f; --gold: #ffd54f;
  --body: "Barlow", system-ui, sans-serif; --mono: "JetBrains Mono", ui-monospace, monospace;
}
* { box-sizing: border-box; }
body { margin: 0; background: transparent; }
/* The banner's colours, kept quiet (gallery/ in this repo): a dark green fading to amber, with a faint grid, and each
   section on a dark panel, like a board picture's rows. No streaks: they showed through between the panels more in
   some pictures than others, so the background is just as calm in every one. */
.card { position: relative; overflow: hidden; width: ${width}px; padding: 14px; border-radius: 14px; border: 1px solid var(--line);
  background:
    linear-gradient(rgba(196, 255, 232, .02) 1px, transparent 1px) 0 0 / 22px 22px,
    linear-gradient(90deg, rgba(196, 255, 232, .02) 1px, transparent 1px) 0 0 / 22px 22px,
    radial-gradient(120% 90% at 0% 0%, #0a3022, transparent 70%),
    linear-gradient(100deg, #061c15 0%, #071511 45%, #161109 100%);
  display: grid; grid-template-columns: repeat(${columns}, minmax(0, 1fr)); gap: 12px; font-family: var(--body); color: var(--ink-2); }
section { position: relative; padding: 0 14px 4px; border-radius: 11px; background: rgba(8, 14, 12, .8); border: 1px solid var(--line); }
/* Waiting for a check: a yellow edge, like the site's held result. Turned down: a red one. */
.card.held section { border-color: rgba(255, 213, 79, .3); }
.card.down section { border-color: rgba(255, 106, 79, .35); }
/* Headings like the site's "Course stats": medium, not semibold, so the i in "Assisted" stays clear */
h2 { margin: 0; padding: 11px 0 6px; font: 500 15px/1.3 var(--body); color: var(--ink); }
.row { display: grid; grid-template-columns: minmax(0, 1fr) auto 62px; align-items: center; gap: 3px 12px; padding: 7px 0; border-top: 1px solid var(--line); }
.label { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font: 600 11.5px/1.3 var(--mono); letter-spacing: .08em; text-transform: uppercase; color: var(--ink-2); }
.value { font: 600 14.5px/1.3 var(--mono); font-variant-numeric: tabular-nums; color: var(--ink); text-align: right; white-space: nowrap; }
.was { font-weight: 500; color: var(--ink-3); }
.chip { justify-self: end; padding: 3px 6px; border-radius: 6px; font: 600 12px/1 var(--mono); white-space: nowrap; }
.chip.up { color: var(--volt); background: rgba(0, 230, 151, .12); }
.chip.down { color: var(--coral); background: rgba(255, 106, 79, .12); }
.chip.new { color: var(--arc); background: rgba(51, 198, 255, .12); }
.note { grid-column: 1 / -1; font: 400 13px/1.4 var(--body); color: var(--ink-2); }
/* Across the top: the logo and the wordmark, as on the website's home page (.wordmark in index.html there): Exo 2,
   BALL in white on an orange shadow, KOUR in the site's green on a dark green one, like the banner */
.brand { grid-column: 1 / -1; display: flex; align-items: center; gap: 14px; padding: 4px 4px 2px; }
.logo { position: relative; width: 54px; height: 54px; flex: none; }
.logo::before { content: ""; position: absolute; inset: -10%; border-radius: 50%; background: conic-gradient(#ff4b3e, #ff9a2e, #ffd23f, #00e697, #33c6ff, #5a6bff, #a54bd8, #ff4b3e); filter: blur(8px); opacity: .45; }
.logo img { position: relative; width: 100%; height: 100%; }
.word { padding-right: .08em; font: italic 900 32px/.9 "Exo 2", "Barlow Condensed", sans-serif; text-transform: uppercase; color: #fff;
  text-shadow: .035em .035em 0 #ff9a2e, 0 0 .45em rgba(0, 230, 151, .3); }
.word b { font-weight: inherit; color: var(--volt); text-shadow: .035em .035em 0 #075c3e, 0 0 .45em rgba(0, 230, 151, .35); }
/* Under it, the banner's line, in its spaced capitals, and at the right, its slanted ballkour.com tag */
.names { display: flex; flex-direction: column; gap: 7px; min-width: 0; }
.tagline { font: 600 10.5px/1 var(--body); letter-spacing: .2em; text-transform: uppercase; color: var(--ink-2); white-space: nowrap; }
.site { margin-left: auto; margin-right: 6px; padding: 7px 14px 7px 12px; background: var(--volt); transform: skewX(-12deg); box-shadow: 3px 3px 0 #ff9a2e; border-radius: 2px; }
.site span { display: inline-block; transform: skewX(12deg); font: 700 15px/1 var(--body); color: #001a10; white-space: nowrap; }
/* The run: the player, the course, Assisted for its assisted board, and the day, with its status at the right */
.runline { grid-column: 1 / -1; display: flex; align-items: center; gap: 12px; padding: 2px 4px 0; font: 500 14px/1.3 var(--body); color: var(--ink-2); white-space: nowrap; }
/* Only the course's name gives way (…) when the line is too long, so the player, the day, and the status always show */
.runinfo { display: flex; align-items: center; gap: 9px; min-width: 0; }
.runinfo .course { min-width: 0; overflow: hidden; text-overflow: ellipsis; }
.runinfo > :not(.course) { flex: none; }
.runline .who { font-weight: 700; color: var(--ink); }
.runline .dot { color: var(--ink-3); }
.mode { padding: 3px 6px; border-radius: 5px; font: 600 10.5px/1 var(--mono); letter-spacing: .1em; text-transform: uppercase; color: #ff80c0; background: rgba(255, 128, 192, .12); border: 1px solid rgba(255, 128, 192, .5); }
.status { flex: none; margin-left: auto; padding: 5px 9px; border-radius: 6px; font: 600 13px/1 var(--body); }
.status.held { color: var(--gold); background: rgba(255, 213, 79, .12); border: 1px solid rgba(255, 213, 79, .45); }
.status.approved { color: var(--volt); background: rgba(0, 230, 151, .12); border: 1px solid rgba(0, 230, 151, .45); }
.status.down { color: var(--coral); background: rgba(255, 106, 79, .12); border: 1px solid rgba(255, 106, 79, .45); }
.chip.same { color: var(--ink-3); background: rgba(255, 255, 255, .06); }
</style></head><body>
<div class="card ${esc(picture.tone || "")}"><div class="brand">${logo ? `<div class="logo"><img src="${esc(logo)}" alt=""></div>` : ""}<div class="names"><span class="word">BALL<b>KOUR</b></span>` +
    `<span class="tagline">Wrecking Ball parkour courses for Overwatch</span></div><span class="site"><span>» ballkour.com</span></span></div>` +
    `${runLine(picture)}${picture.sections.map(section).join("")}</div>
</body></html>`;
}

// What the picture says, for screen readers (Discord's image description, at most 1,024 characters)
export function runCardAlt(picture) {
  const { run, status } = picture;
  const head = run ? `${run.name} on ${run.course}${run.assisted ? " (assisted)" : ""}${run.date ? `, ${run.date}` : ""}${status ? `, ${status.text.toLowerCase()}` : ""}. ` : "";
  const text = head + picture.sections.map((s) => `${s.heading}: ` + s.rows.map((r) =>
    `${r.label} ${r.from !== undefined ? `${r.from} to ` : ""}${r.value}${r.chip && r.chip.tone !== "same" ? ` (${r.chip.text})` : ""}${r.note ? `, ${r.note}` : ""}`).join(", ")).join(". ");
  return text.length > 1024 ? text.slice(0, 1021) + "…" : text;
}

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
 *   { sections: [{ heading, rows: [{ label, value, from?, chip?: { text, tone }, note? }] }], tone }
 * tone is "held" (waiting for a check: yellow), "down" (turned down: red), or "up"/"approved" (green), as the post's
 * colour. A chip's tone is "up" (mint), "down" (coral), "new" (blue), or "same" (grey ▲ 0).
 * columns: how many sections side by side (the first two, then the next two under them, …).
 * width: the card's width in CSS pixels (the picture is twice that, at deviceScaleFactor 2).
 */
export function runCardHtml({ picture, fonts, columns = 2, width = 640 }) {
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
.chip.same { color: var(--ink-3); background: rgba(255, 255, 255, .06); }
</style></head><body>
<div class="card ${esc(picture.tone || "")}">${picture.sections.map(section).join("")}</div>
</body></html>`;
}

// What the picture says, for screen readers (Discord's image description, at most 1,024 characters)
export function runCardAlt(picture) {
  const text = picture.sections.map((s) => `${s.heading}: ` + s.rows.map((r) =>
    `${r.label} ${r.from !== undefined ? `${r.from} to ` : ""}${r.value}${r.chip && r.chip.tone !== "same" ? ` (${r.chip.text})` : ""}${r.note ? `, ${r.note}` : ""}`).join(", ")).join(". ");
  return text.length > 1024 ? text.slice(0, 1021) + "…" : text;
}

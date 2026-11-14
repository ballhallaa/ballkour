// A run's picture: draws its stats (run-card.mjs) and swaps the picture in for the blocks of text in its post on Discord,
// or the DM to its player once a moderator checks it. ballkour.com's Worker posts those as text, then starts
// run-picture.yml with what to draw (see "Run pictures" in cloudflare/worker.js there): POST, as JSON
//   { channel, id, embed, components, picture, expect: { color, footer } }
// channel and id: the message; embed and components: what it becomes, with the picture (embed.image is
// attachment://run.png); picture: what to draw (see runCardHtml); expect: what the message's embed still has to have
// (its colour and the text at its bottom). A message that changed since, because a moderator checked the run in the
// meantime, is left as it is: the Worker starts another run for its new numbers.
//
// DISCORD_BOT_TOKEN: Ballkyrie's, who sent the message. For a test, DISCORD_WEBHOOK (a webhook's URL) instead: the
// message is one that webhook sent, and channel can be left out.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { chromium } from "playwright";
import { api, sleep } from "./discord.mjs";
import { runCardHtml, runCardAlt } from "./run-card.mjs";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const post = JSON.parse(process.env.POST || "null");
const WEBHOOK = process.env.DISCORD_WEBHOOK || "";
if (!post || !/^\d{17,20}$/.test(String(post.id)) || (!WEBHOOK && !/^\d{17,20}$/.test(String(post.channel)))) {
  console.error("POST needs the message's channel and id");
  process.exit(1);
}
if (!post.embed || !post.picture || !Array.isArray(post.picture.sections)) {
  console.error("POST needs the embed and the picture to draw");
  process.exit(1);
}

// The message, through Ballkyrie (or the test webhook, which needs no token)
async function message(method, body) {
  if (!WEBHOOK) return api(method, `/channels/${post.channel}/messages/${post.id}`, body);
  for (let attempt = 0; attempt < 4; attempt++) {
    const isForm = body instanceof FormData;
    const res = await fetch(`${WEBHOOK}/messages/${post.id}?with_components=true`, {
      method,
      headers: body && !isForm ? { "Content-Type": "application/json" } : {},
      body: isForm ? body : body ? JSON.stringify(body) : undefined,
    });
    if (res.status === 429) { await sleep(((await res.json().catch(() => ({}))).retry_after || 1) * 1000 + 250); continue; }
    if (!res.ok) throw new Error(`${method} message ${post.id} → ${res.status} ${await res.text()}`);
    return res.status === 204 ? null : res.json();
  }
  throw new Error(`${method} message ${post.id} → still rate limited`);
}

// Still as the Worker sent it?
const now = await message("GET");
const e = (now.embeds || [])[0] || {};
const expect = post.expect || {};
if ((e.color ?? null) !== (expect.color ?? null) || ((e.footer && e.footer.text) || null) !== (expect.footer ?? null)) {
  console.log(`Message ${post.id} changed since this picture was asked for (a moderator checked the run?), so it's left as it is.`);
  process.exit(0);
}

// The fonts, from @fontsource (as bot.mjs has them)
const file = (pkg, name) => {
  const p = path.join(HERE, "node_modules", pkg, "files", name);
  return fs.existsSync(p) ? pathToFileURL(p).href : "";
};
const fonts = {
  "Barlow-400-normal": file("@fontsource/barlow", "barlow-latin-400-normal.woff2"),
  "Barlow-500-normal": file("@fontsource/barlow", "barlow-latin-500-normal.woff2"),
  "Barlow-600-normal": file("@fontsource/barlow", "barlow-latin-600-normal.woff2"),
  "Barlow-700-normal": file("@fontsource/barlow", "barlow-latin-700-normal.woff2"),
  "JetBrains Mono-500-normal": file("@fontsource/jetbrains-mono", "jetbrains-mono-latin-500-normal.woff2"),
  "JetBrains Mono-600-normal": file("@fontsource/jetbrains-mono", "jetbrains-mono-latin-600-normal.woff2"),
};

// The logo, from the website (as bot.mjs gets it); without it, the picture has the wordmark alone
async function dataUri(url) {
  try {
    const res = await fetch(url);
    if (!res.ok) return "";
    return `data:${res.headers.get("content-type") || "image/png"};base64,${Buffer.from(await res.arrayBuffer()).toString("base64")}`;
  } catch {
    return "";
  }
}
const logo = await dataUri("https://ballkour.com/assets/logo.webp");
// And the wordmark's font, Exo 2: the website's own copy, so it's the same as the home page's wordmark
const exo = await dataUri("https://ballkour.com/assets/fonts/exo-2-latin-900-italic.woff2");
if (exo) fonts["Exo 2-900-italic"] = exo;

const browser = await chromium.launch();
let png;
try {
  const page = await browser.newPage({ viewport: { width: 1000, height: 1200 }, deviceScaleFactor: 2 });
  await page.setContent(runCardHtml({ picture: post.picture, fonts, logo }));
  await page.evaluate(() => document.fonts.ready);
  png = await page.locator(".card").screenshot({ omitBackground: true });
} finally {
  await browser.close();
}
fs.mkdirSync(path.join(HERE, "out"), { recursive: true });
fs.writeFileSync(path.join(HERE, "out", `run-${post.id}.png`), png);

// In it goes: the embed with the picture, in place of the blocks
const form = new FormData();
form.append("payload_json", JSON.stringify({
  embeds: [post.embed],
  components: post.components || [],
  attachments: [{ id: 0, filename: "run.png", description: runCardAlt(post.picture) }],
  allowed_mentions: { parse: [] },
}));
form.append("files[0]", new Blob([png], { type: "image/png" }), "run.png");
await message("PATCH", form);
console.log(`Message ${post.id} has its picture.`);

// Discord's API with the bot's token (DISCORD_BOT_TOKEN), waiting out rate limits. Shared by bot.mjs and roles.mjs.
export const TOKEN = process.env.DISCORD_BOT_TOKEN || "";
const API = "https://discord.com/api/v10";

export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
export async function api(method, route, body) {
  for (let attempt = 0; attempt < 4; attempt++) {
    const isForm = body instanceof FormData;
    const res = await fetch(API + route, {
      method,
      headers: { Authorization: `Bot ${TOKEN}`, ...(body && !isForm ? { "Content-Type": "application/json" } : {}) },
      body: isForm ? body : body ? JSON.stringify(body) : undefined,
    });
    if (res.status === 429) { // rate limited: wait as long as Discord asks
      const wait = (await res.json().catch(() => ({}))).retry_after || 1;
      await sleep(wait * 1000 + 250);
      continue;
    }
    if (!res.ok) {
      const err = new Error(`${method} ${route} → ${res.status} ${await res.text()}`);
      err.status = res.status;
      throw err;
    }
    return res.status === 204 ? null : res.json();
  }
  throw new Error(`${method} ${route} → still rate limited`);
}

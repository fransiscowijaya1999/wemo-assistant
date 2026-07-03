import { Hono } from 'hono';
import type { Bindings } from '../bindings';
import { getChatProvider, resolveAiConfig } from '../ai';
import type { ChatMessage } from '../ai/chat';
import { createCatalogToolset } from '../ai/catalog-tools';
import { getDb } from '../db/client';
import { requireClerkRead } from '../middleware/auth';

export const chatRoute = new Hono<{ Bindings: Bindings }>();

// CLERK-facing assistant. READ-ONLY: it looks up catalog data via read-only
// tools and performs NO writes (see the authorization invariant in CLAUDE.md).
// Guarded by the clerk read token (entered in the mobile app's settings), same
// as /sync — reads only, never the admin token.
const SYSTEM = `You are a parts-identification assistant for a Honda motorcycle spare-parts shop with
an attached workshop, in Indonesia. Customers are often non-technical and arrive WITHOUT a part
number — the broken part may have no visible marking. Your job is to identify the exact correct part
and give its OEM part number.

You are STRICTLY READ-ONLY. You can look things up, summarize, and explain using the provided tools.
You cannot and must not create, change, or delete anything.

How to work:
- Use search_parts to find candidates by part number, name, or a local/colloquial Indonesian term.
- Use get_part for the full detail (all interchangeable numbers, per-color full numbers, aliases, and
  which machine/diagram positions it appears on).
- Always ground answers in tool results — never invent part numbers. If unsure, ask a short
  clarifying question (e.g. which motorcycle model/color).
- Be concise and practical for a busy shop clerk. Reply in the language the clerk used (Indonesian or
  English). When you name a part, include its primary OEM number.`;

chatRoute.post('/', requireClerkRead, async (c) => {
  const body = await c.req.json<{ messages?: ChatMessage[] }>().catch(() => null);
  const messages = (body?.messages ?? []).filter(
    (m) => (m?.role === 'user' || m?.role === 'assistant') && typeof m?.content === 'string' && m.content.trim(),
  );
  if (!messages.length) return c.json({ error: 'messages array is required' }, 400);

  let provider;
  try {
    provider = getChatProvider(await resolveAiConfig(getDb(c.env), c.env));
  } catch (e) {
    return c.json({ error: 'assistant not configured', detail: String(e) }, 503);
  }

  const tools = createCatalogToolset(getDb(c.env));
  try {
    const reply = await provider.chat({
      system: SYSTEM,
      messages: messages.slice(-20), // cap history
      tools: tools.defs,
      executeTool: tools.execute,
    });
    return c.json({ reply, citations: tools.citations() });
  } catch (e) {
    return c.json({ error: 'assistant failed', detail: String(e) }, 502);
  }
});

import { Hono } from 'hono';
import type { Bindings } from '../bindings';
import { getChatProvider, resolveAiConfig } from '../ai';
import type { ChatMessage } from '../ai/chat';
import { createAdminToolset } from '../ai/admin-tools';
import { applyCorrection, ApplyError, correctionProposal } from '../services/corrections';
import { getDb } from '../db/client';
import { requireAdmin } from '../middleware/auth';

export const adminRoute = new Hono<{ Bindings: Bindings }>();

// ADMIN-facing correction assistant. Admin-only (requireAdmin). The assistant can
// look up parts and DRAFT corrections, but performs NO writes: propose_* tools only
// record structured proposals. A write happens solely when the admin approves one
// and calls /admin/corrections/apply. See CLAUDE.md ("never auto-change; human verifies").
const SYSTEM = `You are a catalog-correction assistant for the ADMIN (shop owner) of a Honda motorcycle
spare-parts catalog in Indonesia. You help clean up and correct catalog data.

You CANNOT change anything directly. You DRAFT proposals that the admin reviews and approves; only
then are they applied. Never claim you have changed or saved anything — you propose.

How to work:
- For questions about what the catalog CONTAINS (which machines/models, which assemblies), use list_machines
  and list_assemblies — they are the ground truth. NEVER claim a model is or is not present based on part
  searches; a part search only finds parts you searched for, not the whole catalog.
- Use search_parts / get_part to find the exact part and inspect its current data before proposing.
- Then use the propose_* tools:
  - propose_rename: normalize a raw catalog name (e.g. "GASKET, CYLINDER HEAD" -> "Cylinder Head Gasket"), or fix category/notes.
  - propose_add_alias: add a colloquial/local search term (often Indonesian, e.g. "paking kepala") so clerks can find the part.
  - propose_add_number: add an interchangeable/alternate/superseded/aftermarket number the part is missing.
  - propose_edit_number: fix a typo in an existing number, or correct its kind/brand.
- Ground every proposal in a real part you looked up. Propose only what the admin asked for or clearly
  confirmed. Prefer several small, precise proposals over one sweeping change.
- Be concise. Reply in the admin's language (Indonesian or English). After proposing, briefly say what
  you proposed and that it is awaiting their approval.`;

adminRoute.post('/chat', requireAdmin, async (c) => {
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

  const tools = createAdminToolset(getDb(c.env));
  try {
    const reply = await provider.chat({
      system: SYSTEM,
      messages: messages.slice(-20),
      tools: tools.defs,
      executeTool: tools.execute,
    });
    return c.json({ reply, proposals: tools.proposals() });
  } catch (e) {
    return c.json({ error: 'assistant failed', detail: String(e) }, 502);
  }
});

// Apply ONE approved correction. This is the only write path for the assistant flow.
adminRoute.post('/corrections/apply', requireAdmin, async (c) => {
  const body = await c.req.json<{ proposal?: unknown }>().catch(() => null);
  const parsed = correctionProposal.safeParse(body?.proposal);
  if (!parsed.success) {
    return c.json({ error: 'invalid proposal', detail: parsed.error.issues }, 400);
  }
  try {
    const { summary } = await applyCorrection(getDb(c.env), parsed.data);
    return c.json({ ok: true, summary });
  } catch (e) {
    if (e instanceof ApplyError) return c.json({ error: e.message }, 409);
    return c.json({ error: 'apply failed', detail: String(e) }, 500);
  }
});

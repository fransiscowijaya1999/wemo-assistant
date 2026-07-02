import { Hono } from 'hono';
import { eq } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { appSettings } from '../db/schema';
import { AI_SETTING_KEYS, activeChatProvider, resolveAiConfig } from '../ai/config';
import { DEFAULT_VISION_MODEL } from '../ai/anthropic';
import { requireAdmin } from '../middleware/auth';

export const settingsRoute = new Hono<{ Bindings: Bindings }>();

// Admin-only AI provider config. Values stored here override env/secrets so the
// owner can rotate keys or switch providers from the admin UI without a deploy.
// Keys are returned to authenticated admins by design (the owner asked to see
// them); this is an internal single-shop tool and every route here requires the
// admin bearer token.

async function aiView(db: ReturnType<typeof getDb>, env: Bindings) {
  const cfg = await resolveAiConfig(db, env);
  return {
    chatProvider: cfg.chatProvider,
    chatModel: cfg.chatModel ?? '',
    visionModel: cfg.visionModel ?? '',
    visionModelEffective: cfg.visionModel ?? DEFAULT_VISION_MODEL,
    anthropicKey: cfg.anthropicKey ?? '',
    deepseekKey: cfg.deepseekKey ?? '',
    activeChatProvider: activeChatProvider(cfg),
    visionConfigured: !!cfg.anthropicKey,
  };
}

settingsRoute.get('/ai', requireAdmin, async (c) => {
  const db = getDb(c.env);
  return c.json(await aiView(db, c.env));
});

settingsRoute.put('/ai', requireAdmin, async (c) => {
  const body = await c.req
    .json<{
      chatProvider?: string;
      chatModel?: string;
      visionModel?: string;
      anthropicKey?: string;
      deepseekKey?: string;
    }>()
    .catch(() => null);
  if (!body) return c.json({ error: 'invalid JSON body' }, 400);

  const provider = body.chatProvider?.trim().toLowerCase();
  // '' clears the override (env fallback resumes); undefined leaves it untouched.
  if (provider !== undefined && provider !== '' && !['auto', 'anthropic', 'deepseek', 'stub'].includes(provider)) {
    return c.json({ error: "chatProvider must be 'auto', 'anthropic', 'deepseek' or 'stub'" }, 400);
  }
  // Extraction always runs on Anthropic — DeepSeek's public API has no image input,
  // so a non-Anthropic model here would only break the next extraction.
  const visionModel = body.visionModel?.trim();
  if (visionModel && !visionModel.toLowerCase().startsWith('claude')) {
    return c.json(
      { error: `extraction runs on Anthropic only — the model must be a 'claude-*' id (default ${DEFAULT_VISION_MODEL}). DeepSeek's API has no image input.` },
      400,
    );
  }

  const db = getDb(c.env);
  const updates: [string, string | undefined][] = [
    [AI_SETTING_KEYS.chatProvider, provider],
    [AI_SETTING_KEYS.chatModel, body.chatModel?.trim()],
    [AI_SETTING_KEYS.visionModel, visionModel],
    [AI_SETTING_KEYS.anthropicKey, body.anthropicKey?.trim()],
    [AI_SETTING_KEYS.deepseekKey, body.deepseekKey?.trim()],
  ];
  for (const [key, value] of updates) {
    if (value === undefined) continue; // field not sent -> leave as-is
    if (value === '') {
      // Empty clears the override; env/secret fallback resumes.
      await db.delete(appSettings).where(eq(appSettings.key, key));
    } else {
      await db
        .insert(appSettings)
        .values({ key, value })
        .onConflictDoUpdate({ target: appSettings.key, set: { value, updatedAt: new Date() } });
    }
  }

  return c.json(await aiView(db, c.env));
});

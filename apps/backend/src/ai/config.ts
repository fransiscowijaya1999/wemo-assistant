import { like } from 'drizzle-orm';
import type { Db } from '../db/client';
import { appSettings } from '../db/schema';
import type { Bindings } from '../bindings';

/**
 * Runtime AI configuration: admin-editable values stored in `app_settings` (D1)
 * take precedence; env vars / worker secrets are the fallback. This lets the shop
 * owner rotate keys or switch chat providers from the admin UI without a deploy.
 */
export type AiConfig = {
  /** 'auto' | 'anthropic' | 'deepseek' | 'stub' */
  chatProvider: string;
  chatModel?: string;
  anthropicKey?: string;
  deepseekKey?: string;
};

export const AI_SETTING_KEYS = {
  chatProvider: 'ai.chat_provider',
  chatModel: 'ai.chat_model',
  anthropicKey: 'ai.anthropic_api_key',
  deepseekKey: 'ai.deepseek_api_key',
} as const;

export async function resolveAiConfig(db: Db, env: Bindings): Promise<AiConfig> {
  const rows = await db.select().from(appSettings).where(like(appSettings.key, 'ai.%'));
  const stored = new Map(rows.map((r) => [r.key, r.value]));
  const pick = (key: string, envValue?: string) => {
    const v = stored.get(key)?.trim();
    return v ? v : envValue;
  };
  return {
    chatProvider: (
      pick(AI_SETTING_KEYS.chatProvider, env.AI_CHAT === 'stub' ? 'stub' : env.CHAT_PROVIDER) ?? 'auto'
    ).toLowerCase(),
    chatModel: pick(AI_SETTING_KEYS.chatModel, env.CHAT_MODEL),
    anthropicKey: pick(AI_SETTING_KEYS.anthropicKey, env.ANTHROPIC_API_KEY),
    deepseekKey: pick(AI_SETTING_KEYS.deepseekKey, env.DEEPSEEK_API_KEY),
  };
}

/** Which chat provider a config resolves to, without instantiating it. */
export function activeChatProvider(cfg: AiConfig): 'anthropic' | 'deepseek' | 'stub' | null {
  if (cfg.chatProvider === 'stub') return 'stub';
  if (cfg.chatProvider === 'deepseek') return cfg.deepseekKey ? 'deepseek' : null;
  if (cfg.chatProvider === 'anthropic') return cfg.anthropicKey ? 'anthropic' : null;
  if (cfg.anthropicKey) return 'anthropic';
  if (cfg.deepseekKey) return 'deepseek';
  return null;
}

import type { VisionExtractionProvider } from './provider';
import { createAnthropicVisionProvider } from './anthropic';
import type { ChatProvider } from './chat';
import { createAnthropicChatProvider } from './anthropic-chat';
import { createDeepSeekChatProvider } from './deepseek-chat';
import { createStubChatProvider } from './chat-stub';
import type { AiConfig } from './config';

/**
 * Model-agnostic factories. Config is resolved by `resolveAiConfig` (admin-edited
 * D1 settings first, env/secrets as fallback) so keys/providers can change at
 * runtime without a deploy.
 */
export function getVisionProvider(cfg: AiConfig): VisionExtractionProvider {
  if (!cfg.anthropicKey) {
    throw new Error('Anthropic API key is not configured (Settings → AI provider, or ANTHROPIC_API_KEY)');
  }
  return createAnthropicVisionProvider(cfg.anthropicKey);
}

/**
 * Chat factory for the CLERK assistant (read-only). Selection:
 *   1. provider 'stub' → keyless stub.
 *   2. provider explicitly set → that provider (needs its key).
 *   3. 'auto' → whichever API key is present (Anthropic first).
 * Every provider gets the SAME read-only tools; none can mutate.
 */
export function getChatProvider(cfg: AiConfig): ChatProvider {
  if (cfg.chatProvider === 'stub') return createStubChatProvider();

  if (cfg.chatProvider === 'deepseek') {
    if (!cfg.deepseekKey) throw new Error('DeepSeek API key is not configured');
    return createDeepSeekChatProvider(cfg.deepseekKey, cfg.chatModel);
  }
  if (cfg.chatProvider === 'anthropic') {
    if (!cfg.anthropicKey) throw new Error('Anthropic API key is not configured');
    return createAnthropicChatProvider(cfg.anthropicKey, cfg.chatModel);
  }

  // Auto-detect.
  if (cfg.anthropicKey) return createAnthropicChatProvider(cfg.anthropicKey, cfg.chatModel);
  if (cfg.deepseekKey) return createDeepSeekChatProvider(cfg.deepseekKey, cfg.chatModel);
  throw new Error('No chat provider configured (set a key in Settings → AI provider, or use the stub)');
}

export { resolveAiConfig, activeChatProvider } from './config';
export type { AiConfig } from './config';
export type { VisionExtractionProvider } from './provider';
export type { ChatProvider } from './chat';

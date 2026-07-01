import type { Bindings } from '../bindings';
import type { VisionExtractionProvider } from './provider';
import { createAnthropicVisionProvider } from './anthropic';
import type { ChatProvider } from './chat';
import { createAnthropicChatProvider } from './anthropic-chat';
import { createDeepSeekChatProvider } from './deepseek-chat';
import { createStubChatProvider } from './chat-stub';

/**
 * Model-agnostic factory. Today it returns the Claude implementation; later this
 * can switch on an env var (e.g. AI_PROVIDER) to pick OpenAI/Gemini/local.
 */
export function getVisionProvider(env: Bindings): VisionExtractionProvider {
  if (!env.ANTHROPIC_API_KEY) {
    throw new Error('ANTHROPIC_API_KEY is not configured');
  }
  return createAnthropicVisionProvider(env.ANTHROPIC_API_KEY);
}

/**
 * Model-agnostic chat factory for the CLERK assistant (read-only). Selection:
 *   1. AI_CHAT=stub (or CHAT_PROVIDER=stub) → keyless stub.
 *   2. CHAT_PROVIDER explicitly set → that provider (needs its key).
 *   3. otherwise auto-detect by whichever API key is present.
 * Every provider gets the SAME read-only tools; none can mutate.
 */
export function getChatProvider(env: Bindings): ChatProvider {
  const which = (env.CHAT_PROVIDER ?? '').toLowerCase();

  if (which === 'stub' || env.AI_CHAT === 'stub') return createStubChatProvider();

  if (which === 'deepseek') {
    if (!env.DEEPSEEK_API_KEY) throw new Error('DEEPSEEK_API_KEY is not configured');
    return createDeepSeekChatProvider(env.DEEPSEEK_API_KEY, env.CHAT_MODEL);
  }
  if (which === 'anthropic') {
    if (!env.ANTHROPIC_API_KEY) throw new Error('ANTHROPIC_API_KEY is not configured');
    return createAnthropicChatProvider(env.ANTHROPIC_API_KEY, env.CHAT_MODEL);
  }

  // Auto-detect.
  if (env.ANTHROPIC_API_KEY) return createAnthropicChatProvider(env.ANTHROPIC_API_KEY, env.CHAT_MODEL);
  if (env.DEEPSEEK_API_KEY) return createDeepSeekChatProvider(env.DEEPSEEK_API_KEY, env.CHAT_MODEL);
  throw new Error('No chat provider configured (set ANTHROPIC_API_KEY, DEEPSEEK_API_KEY, or AI_CHAT=stub)');
}

export type { VisionExtractionProvider } from './provider';
export type { ChatProvider } from './chat';

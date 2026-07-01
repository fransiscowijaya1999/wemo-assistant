import type { Bindings } from '../bindings';
import type { VisionExtractionProvider } from './provider';
import { createAnthropicVisionProvider } from './anthropic';
import type { ChatProvider } from './chat';
import { createAnthropicChatProvider } from './anthropic-chat';
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
 * Model-agnostic chat factory for the CLERK assistant (read-only). Returns the
 * stub when AI_CHAT=stub (keyless local testing), else the Claude implementation.
 */
export function getChatProvider(env: Bindings): ChatProvider {
  if (env.AI_CHAT === 'stub') return createStubChatProvider();
  if (!env.ANTHROPIC_API_KEY) {
    throw new Error('ANTHROPIC_API_KEY is not configured');
  }
  return createAnthropicChatProvider(env.ANTHROPIC_API_KEY, env.CHAT_MODEL);
}

export type { VisionExtractionProvider } from './provider';
export type { ChatProvider } from './chat';

import type { Bindings } from '../bindings';
import type { VisionExtractionProvider } from './provider';
import { createAnthropicVisionProvider } from './anthropic';

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

export type { VisionExtractionProvider } from './provider';

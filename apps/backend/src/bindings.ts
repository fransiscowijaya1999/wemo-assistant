export type Bindings = {
  DB: D1Database;
  IMAGES: R2Bucket;
  /** Bearer token authorizing admin (write) requests. Set in .dev.vars locally. */
  ADMIN_TOKEN?: string;
  /** AI provider key for catalog ingestion + clerk assistant. Set in .dev.vars locally / wrangler secret in prod. */
  ANTHROPIC_API_KEY?: string;
  /** DeepSeek key (OpenAI-compatible) — an alternative chat provider for the clerk assistant. */
  DEEPSEEK_API_KEY?: string;
  /** Explicit chat provider: 'anthropic' | 'deepseek' | 'stub'. Omitted = auto-detect by key. */
  CHAT_PROVIDER?: string;
  /** Optional chat model override (default: claude-opus-4-8 for Anthropic, deepseek-chat for DeepSeek). */
  CHAT_MODEL?: string;
  /** Optional vision/extraction model override (default: claude-opus-4-8). */
  VISION_MODEL?: string;
  /** Set to 'stub' to run the clerk assistant without an API key (local dev/testing). */
  AI_CHAT?: string;
};

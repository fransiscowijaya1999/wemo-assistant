export type Bindings = {
  DB: D1Database;
  IMAGES: R2Bucket;
  /** Bearer token authorizing admin (write) requests. Set in .dev.vars locally. */
  ADMIN_TOKEN?: string;
  /** AI provider key for catalog ingestion + clerk assistant. Set in .dev.vars locally / wrangler secret in prod. */
  ANTHROPIC_API_KEY?: string;
  /** Optional chat model override for the clerk assistant (default claude-opus-4-8). */
  CHAT_MODEL?: string;
  /** Set to 'stub' to run the clerk assistant without an API key (local dev/testing). */
  AI_CHAT?: string;
};

export type Bindings = {
  DB: D1Database;
  IMAGES: R2Bucket;
  /** Bearer token authorizing admin (write) requests. Set in .dev.vars locally. */
  ADMIN_TOKEN?: string;
  /** AI provider key for catalog ingestion. Set in .dev.vars locally / wrangler secret in prod. */
  ANTHROPIC_API_KEY?: string;
};

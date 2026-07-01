export type Bindings = {
  DB: D1Database;
  IMAGES: R2Bucket;
  /** Bearer token authorizing admin (write) requests. Set in .dev.vars locally. */
  ADMIN_TOKEN?: string;
};

import { createMiddleware } from 'hono/factory';
import type { Bindings } from '../bindings';

/**
 * Guards every mutation. Writes are admin-only.
 *
 * The clerk app (and any AI acting on the clerk's behalf) is strictly read-only: it has no mutation
 * routes and never presents this token. This middleware is the single choke point protecting all
 * create/update/delete operations. A missing ADMIN_TOKEN denies by default.
 */
export const requireAdmin = createMiddleware<{ Bindings: Bindings }>(async (c, next) => {
  const token = c.env.ADMIN_TOKEN;
  const provided = c.req.header('Authorization');
  if (!token || provided !== `Bearer ${token}`) {
    return c.json({ error: 'admin authorization required' }, 401);
  }
  await next();
});

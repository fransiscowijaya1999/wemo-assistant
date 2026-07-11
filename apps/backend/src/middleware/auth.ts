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

/**
 * Guards clerk-facing reads (/sync, /chat). The clerk app presents CLERK_TOKEN — entered by hand
 * in the app's Sync settings, never compiled into the APK. It authorizes reads only; mutations
 * still require ADMIN_TOKEN (which is also accepted here, so the admin can use the clerk app).
 * A missing CLERK_TOKEN denies by default.
 */
export const requireClerkRead = createMiddleware<{ Bindings: Bindings }>(async (c, next) => {
  const provided = c.req.header('Authorization');
  const ok =
    (c.env.CLERK_TOKEN && provided === `Bearer ${c.env.CLERK_TOKEN}`) ||
    (c.env.ADMIN_TOKEN && provided === `Bearer ${c.env.ADMIN_TOKEN}`);
  if (!ok) {
    return c.json({ error: 'clerk authorization required' }, 401);
  }
  await next();
});

/**
 * Guards CRM write operations. Both clerk and admin can write to CRM tables.
 * Clerk app presents CLERK_TOKEN, admin presents ADMIN_TOKEN.
 */
export const requireClerkWrite = createMiddleware<{ Bindings: Bindings }>(async (c, next) => {
  const provided = c.req.header('Authorization');
  const ok =
    (c.env.CLERK_TOKEN && provided === `Bearer ${c.env.CLERK_TOKEN}`) ||
    (c.env.ADMIN_TOKEN && provided === `Bearer ${c.env.ADMIN_TOKEN}`);
  if (!ok) {
    return c.json({ error: 'clerk or admin authorization required' }, 401);
  }
  await next();
});

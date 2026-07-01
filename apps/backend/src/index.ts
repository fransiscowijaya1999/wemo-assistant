import { Hono } from 'hono';

export type Bindings = {
  DB: D1Database;
  IMAGES: R2Bucket;
};

const app = new Hono<{ Bindings: Bindings }>();

app.get('/', (c) => c.json({ name: 'wemo-backend', status: 'ok' }));

// DB connectivity check that does not depend on migrations having run.
app.get('/health', async (c) => {
  const row = await c.env.DB.prepare('select 1 as ok').first<{ ok: number }>();
  return c.json({ ok: row?.ok === 1 });
});

export default app;

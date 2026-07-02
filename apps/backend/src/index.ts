import { Hono } from 'hono';
import type { Bindings } from './bindings';
import { requireAdmin } from './middleware/auth';
import { machinesRoute } from './routes/machines';
import { assembliesRoute } from './routes/assemblies';
import { partsRoute } from './routes/parts';
import { ingestRoute } from './routes/ingest';
import { syncRoute } from './routes/sync';
import { chatRoute } from './routes/chat';
import { settingsRoute } from './routes/settings';

const app = new Hono<{ Bindings: Bindings }>();

app.get('/', (c) => c.json({ name: 'wemo-backend', status: 'ok' }));

// DB connectivity check that does not depend on migrations having run.
app.get('/health', async (c) => {
  const row = await c.env.DB.prepare('select 1 as ok').first<{ ok: number }>();
  return c.json({ ok: row?.ok === 1 });
});

// Admin-token check (no side effects) — used by the admin Settings "Test connection".
app.get('/auth/check', requireAdmin, (c) => c.json({ ok: true }));

app.route('/machines', machinesRoute);
app.route('/assemblies', assembliesRoute);
app.route('/parts', partsRoute);
app.route('/ingest', ingestRoute);
app.route('/sync', syncRoute);
app.route('/chat', chatRoute);
app.route('/settings', settingsRoute);

export default app;
export type { Bindings };

import { defineConfig } from 'drizzle-kit';

// Used by `drizzle-kit generate` to emit SQL migrations into ./drizzle from the
// Drizzle schema. Migrations are applied to D1 via `wrangler d1 migrations apply`.
export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'sqlite',
});

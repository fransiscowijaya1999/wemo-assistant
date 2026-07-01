import { drizzle } from 'drizzle-orm/d1';
import type { Bindings } from '../bindings';
import * as schema from './schema';

export const getDb = (env: Bindings) => drizzle(env.DB, { schema });
export type Db = ReturnType<typeof getDb>;

import { Hono } from 'hono';
import { and, eq, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { maintenanceItems } from '../db/schema';
import { requireAdmin } from '../middleware/auth';

export const statsRoute = new Hono<{ Bindings: Bindings }>();

// Brand usage statistics (admin only)
statsRoute.get('/records/brands', requireAdmin, async (c) => {
  const db = getDb(c.env);
  const limit = Math.min(Number(c.req.query('limit')) || 20, 100);

  // Get items with brands
  const allItems = await db
    .select({ brand: maintenanceItems.brand })
    .from(maintenanceItems)
    .where(isNull(maintenanceItems.deletedAt))
    .limit(limit * 10);

  // Simple brand list (no counting in this simplified version)
  const brandCounts: Record<string, number> = {};
  
  for (const item of allItems) {
    if (item.brand) {
      brandCounts[item.brand] = (brandCounts[item.brand] || 0) + 1;
    }
  }

  return c.json({ brands: Object.entries(brandCounts).map(([brand, count]) => ({ brand, count })) });
});

// Expiring warranties (admin only)
statsRoute.get('/warranty/expiring', requireAdmin, async (c) => {
  const db = getDb(c.env);
  const days = Number(c.req.query('days')) || 30;
  const limit = Math.min(Number(c.req.query('limit')) || 50, 500);

  const now = Date.now();
  const expiryThreshold = now + days * 24 * 60 * 60 * 1000;

  // Get items with warranty that will expire soon
  const items = await db
    .select()
    .from(maintenanceItems)
    .where(and(
      isNull(maintenanceItems.deletedAt),
      eq(maintenanceItems.hasWarranty as any, 1)
    ))
    .limit(limit);

  // Filter and calculate expiry in memory
  const expiring = [];
  for (const item of items) {
    const expiryDate = Number(item.warrantyExpiryDate) || 0;
    const daysUntilExpiry = Math.ceil((expiryDate - now) / (24 * 60 * 60 * 1000));
    
    if (expiryDate > now && expiryDate <= expiryThreshold) {
      expiring.push({
        ...item,
        daysUntilExpiry,
        expiryDate: new Date(expiryDate).toISOString()
      });
    }
  }

  return c.json({ expiring, daysThreshold: days, count: expiring.length });
});
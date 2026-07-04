import { and, eq, inArray, isNull } from 'drizzle-orm';
import type { Db } from '../db/client';
import {
  assemblies,
  assemblyItems,
  assemblyLinks,
  colors,
  dots,
  itemResolutions,
  machineVariants,
  machines,
  partColorVariants,
  serviceItems,
} from '../db/schema';

/**
 * Soft-delete a machine and every row it owns, so the tombstones propagate to the offline
 * clerk replicas via `GET /sync`. A machine owns a deep tree — assemblies -> assembly_items
 * -> item_resolutions + dots, plus service_items, assembly_links, machine_variants, and
 * colors -> part_color_variants.
 *
 * `parts` / `part_numbers` / `aliases` are canonical and shared across machines and are
 * deliberately left untouched (see docs/schema.md — "parts never duplicated").
 *
 * Cascades via subquery `inArray` rather than fetched id-lists so we never hit D1's ~100
 * bound-param cap on big catalogs. Every update guards `isNull(deletedAt)`, so re-deleting an
 * already-deleted machine is a no-op.
 */
export async function softDeleteMachine(db: Db, machineId: string): Promise<void> {
  const tombstone = { deletedAt: new Date(), updatedAt: new Date() };

  // Live assemblies / positions / colors of this machine, as subqueries (no id fetch).
  const asmIds = db
    .select({ id: assemblies.id })
    .from(assemblies)
    .where(and(eq(assemblies.machineId, machineId), isNull(assemblies.deletedAt)));
  const itemIds = db
    .select({ id: assemblyItems.id })
    .from(assemblyItems)
    .where(and(inArray(assemblyItems.assemblyId, asmIds), isNull(assemblyItems.deletedAt)));
  const colorIds = db
    .select({ id: colors.id })
    .from(colors)
    .where(and(eq(colors.machineId, machineId), isNull(colors.deletedAt)));

  // Children -> parent.
  await db
    .update(itemResolutions)
    .set(tombstone)
    .where(and(inArray(itemResolutions.assemblyItemId, itemIds), isNull(itemResolutions.deletedAt)));
  await db
    .update(dots)
    .set(tombstone)
    .where(and(inArray(dots.assemblyItemId, itemIds), isNull(dots.deletedAt)));
  await db
    .update(assemblyItems)
    .set(tombstone)
    .where(and(inArray(assemblyItems.assemblyId, asmIds), isNull(assemblyItems.deletedAt)));
  await db
    .update(serviceItems)
    .set(tombstone)
    .where(and(inArray(serviceItems.assemblyId, asmIds), isNull(serviceItems.deletedAt)));
  await db
    .update(assemblyLinks)
    .set(tombstone)
    .where(and(inArray(assemblyLinks.fromAssemblyId, asmIds), isNull(assemblyLinks.deletedAt)));
  await db
    .update(assemblies)
    .set(tombstone)
    .where(and(eq(assemblies.machineId, machineId), isNull(assemblies.deletedAt)));

  await db
    .update(partColorVariants)
    .set(tombstone)
    .where(and(inArray(partColorVariants.colorId, colorIds), isNull(partColorVariants.deletedAt)));
  await db
    .update(colors)
    .set(tombstone)
    .where(and(eq(colors.machineId, machineId), isNull(colors.deletedAt)));
  await db
    .update(machineVariants)
    .set(tombstone)
    .where(and(eq(machineVariants.machineId, machineId), isNull(machineVariants.deletedAt)));

  await db
    .update(machines)
    .set(tombstone)
    .where(and(eq(machines.id, machineId), isNull(machines.deletedAt)));
}

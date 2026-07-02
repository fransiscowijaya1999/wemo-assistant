import { and, eq, inArray, isNull } from 'drizzle-orm';
import type { Db } from '../db/client';
import {
  assemblies,
  assemblyItems,
  dots,
  itemResolutions,
  machineVariants,
  partNumbers,
  parts,
  serviceItems,
} from '../db/schema';
import type { ExtractedPage } from '../ai/types';

export type PersistInput = {
  machineId: string;
  groupType: 'engine' | 'frame';
  extracted: ExtractedPage;
};

export type PersistSummary = {
  assemblyId: string;
  itemsCreated: number;
  partsCreated: number;
  partsReused: number;
  numbersCreated: number;
  serviceItemsCreated: number;
  resolutionsCreated: number;
  machineVariantsCreated: number;
  assembliesReplaced: number;
};

/**
 * Persists a reviewed extraction into the catalog tables.
 *
 * Merge policy: parts are canonical and deduped by part number. If any of an item's
 * numbers already exists, that number's part is reused (interchange merge); otherwise a
 * new part is created. When an item lists several numbers that map to different existing
 * parts, the first match wins — full human-mediated merge is an admin-UI concern (later).
 *
 * Re-ingest: committing a page soft-deletes any live assembly with the same
 * (machineId, code) and its children first, so re-running a page replaces it instead of
 * duplicating it (deletions propagate to replicas via /sync).
 *
 * Note: D1 has no interactive transactions in the Drizzle session, so inserts run
 * sequentially (not atomic). Acceptable for the review-then-commit flow; batch later.
 */
export async function persistExtractedPage(db: Db, input: PersistInput): Promise<PersistSummary> {
  const { machineId, groupType, extracted } = input;
  const summary: PersistSummary = {
    assemblyId: '',
    itemsCreated: 0,
    partsCreated: 0,
    partsReused: 0,
    numbersCreated: 0,
    serviceItemsCreated: 0,
    resolutionsCreated: 0,
    machineVariantsCreated: 0,
    assembliesReplaced: 0,
  };

  summary.assembliesReplaced = await softDeleteExistingAssemblies(db, machineId, extracted.assembly.code);

  // Machine variants referenced by per-variant quantities, get-or-created by name
  // (case-insensitive) so STD/ABS exist exactly once per machine across pages.
  const liveVariants = await db
    .select({ id: machineVariants.id, name: machineVariants.name })
    .from(machineVariants)
    .where(and(eq(machineVariants.machineId, machineId), isNull(machineVariants.deletedAt)));
  const variantIdByName = new Map(liveVariants.map((v) => [v.name.trim().toLowerCase(), v.id]));

  async function variantIdFor(name: string): Promise<string> {
    const key = name.trim().toLowerCase();
    const found = variantIdByName.get(key);
    if (found) return found;
    const [created] = await db.insert(machineVariants).values({ machineId, name: name.trim() }).returning();
    variantIdByName.set(key, created.id);
    summary.machineVariantsCreated++;
    return created.id;
  }

  const [assembly] = await db
    .insert(assemblies)
    .values({
      machineId,
      groupType,
      code: extracted.assembly.code,
      name: extracted.assembly.name,
      imageCode: extracted.assembly.imageCode ?? null,
    })
    .returning();
  summary.assemblyId = assembly.id;

  for (const item of extracted.items) {
    // Resolve the canonical part: reuse an existing part if any number already exists.
    let partId: string | null = null;
    for (const pn of item.partNumbers) {
      const existing = await db
        .select({ partId: partNumbers.partId })
        .from(partNumbers)
        .where(eq(partNumbers.value, pn.value))
        .get();
      if (existing) {
        partId = existing.partId;
        break;
      }
    }
    if (partId) {
      summary.partsReused++;
    } else {
      const [created] = await db.insert(parts).values({ nameRaw: item.description }).returning();
      partId = created.id;
      summary.partsCreated++;
    }

    const [assemblyItem] = await db
      .insert(assemblyItems)
      .values({ assemblyId: assembly.id, refNo: item.refNo, basePartId: partId })
      .returning();
    summary.itemsCreated++;

    // Ensure each number exists (attach new ones to the canonical part), then link it
    // to this position via item_resolutions with the quantity.
    let isFirst = true;
    for (const pn of item.partNumbers) {
      let numberRow = await db
        .select()
        .from(partNumbers)
        .where(eq(partNumbers.value, pn.value))
        .get();
      if (!numberRow) {
        const [inserted] = await db
          .insert(partNumbers)
          .values({
            partId,
            value: pn.value,
            brand: pn.brand ?? null,
            note: pn.note ?? null,
            isPrimary: isFirst,
          })
          .returning();
        numberRow = inserted;
        summary.numbersCreated++;
      }
      // One resolution row per applicable variant (per-variant Jumlah cells), or a single
      // variant-less row (= applies to all variants) when the page has one QTY column.
      // A number absent from a variant's column gets no row for that variant.
      const variantQtys = pn.variantQtys?.filter((vq) => vq.variant.trim()) ?? [];
      if (variantQtys.length > 0) {
        for (const vq of variantQtys) {
          await db.insert(itemResolutions).values({
            assemblyItemId: assemblyItem.id,
            partNumberId: numberRow.id,
            qty: vq.qty ?? item.qty ?? 1,
            variantId: await variantIdFor(vq.variant),
            serialFrom: pn.serialFrom ?? null,
            serialTo: pn.serialTo ?? null,
          });
          summary.resolutionsCreated++;
        }
      } else {
        await db.insert(itemResolutions).values({
          assemblyItemId: assemblyItem.id,
          partNumberId: numberRow.id,
          qty: item.qty ?? 1,
          serialFrom: pn.serialFrom ?? null,
          serialTo: pn.serialTo ?? null,
        });
        summary.resolutionsCreated++;
      }
      isFirst = false;
    }
  }

  for (const svc of extracted.serviceItems) {
    await db.insert(serviceItems).values({
      assemblyId: assembly.id,
      refNo: svc.refNo ?? null,
      name: svc.name,
      frtHours: svc.frtHours ?? null,
    });
    summary.serviceItemsCreated++;
  }

  return summary;
}

/**
 * Soft-deletes any live assembly with the same (machineId, code) plus its items,
 * resolutions, dots and service items. Parts/part_numbers are canonical and shared —
 * they are never deleted here. Returns how many assemblies were replaced.
 */
async function softDeleteExistingAssemblies(db: Db, machineId: string, code: string): Promise<number> {
  const existing = await db
    .select({ id: assemblies.id })
    .from(assemblies)
    .where(and(eq(assemblies.machineId, machineId), eq(assemblies.code, code), isNull(assemblies.deletedAt)));
  if (existing.length === 0) return 0;
  const assemblyIds = existing.map((a) => a.id);

  const items = await db
    .select({ id: assemblyItems.id })
    .from(assemblyItems)
    .where(and(inArray(assemblyItems.assemblyId, assemblyIds), isNull(assemblyItems.deletedAt)));
  const itemIds = items.map((i) => i.id);

  const tombstone = { deletedAt: new Date(), updatedAt: new Date() };
  if (itemIds.length > 0) {
    await db.update(itemResolutions).set(tombstone)
      .where(and(inArray(itemResolutions.assemblyItemId, itemIds), isNull(itemResolutions.deletedAt)));
    await db.update(dots).set(tombstone)
      .where(and(inArray(dots.assemblyItemId, itemIds), isNull(dots.deletedAt)));
    await db.update(assemblyItems).set(tombstone).where(inArray(assemblyItems.id, itemIds));
  }
  await db.update(serviceItems).set(tombstone)
    .where(and(inArray(serviceItems.assemblyId, assemblyIds), isNull(serviceItems.deletedAt)));
  await db.update(assemblies).set(tombstone).where(inArray(assemblies.id, assemblyIds));

  return assemblyIds.length;
}

import { eq } from 'drizzle-orm';
import type { Db } from '../db/client';
import { assemblies, assemblyItems, itemResolutions, partNumbers, parts, serviceItems } from '../db/schema';
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
};

/**
 * Persists a reviewed extraction into the catalog tables.
 *
 * Merge policy: parts are canonical and deduped by part number. If any of an item's
 * numbers already exists, that number's part is reused (interchange merge); otherwise a
 * new part is created. When an item lists several numbers that map to different existing
 * parts, the first match wins — full human-mediated merge is an admin-UI concern (later).
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
  };

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
      await db.insert(itemResolutions).values({
        assemblyItemId: assemblyItem.id,
        partNumberId: numberRow.id,
        qty: item.qty ?? 1,
      });
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

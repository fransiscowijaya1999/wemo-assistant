import { and, eq } from 'drizzle-orm';
import type { Db } from '../db/client';
import { colors, partColorVariants, partNumbers, parts } from '../db/schema';
import type { ExtractedColorPage } from '../ai/types';

export type ColorPersistInput = {
  machineId: string;
  extracted: ExtractedColorPage;
};

export type ColorPersistSummary = {
  colorsCreated: number;
  colorsReused: number;
  partsCreated: number;
  partsReused: number;
  variantsCreated: number;
  variantsSkipped: number;
};

/**
 * Persists a reviewed color-index extraction. Colors are deduped per machine by code.
 * Parts are found-or-created by base number (reusing the canonical part if the base number
 * already exists). Each non-empty color cell becomes a part_color_variants row with
 * fullNumber = base + suffix. Variants already present for a part+color are skipped.
 * (block/ref cross-links are captured in the draft but linked to positions later, with the UI.)
 */
export async function persistColorPage(db: Db, input: ColorPersistInput): Promise<ColorPersistSummary> {
  const { machineId, extracted } = input;
  const summary: ColorPersistSummary = {
    colorsCreated: 0,
    colorsReused: 0,
    partsCreated: 0,
    partsReused: 0,
    variantsCreated: 0,
    variantsSkipped: 0,
  };

  const colorIdByCode = new Map<string, string>();
  for (const col of extracted.colors) {
    const existing = await db
      .select({ id: colors.id })
      .from(colors)
      .where(and(eq(colors.machineId, machineId), eq(colors.code, col.code)))
      .get();
    if (existing) {
      colorIdByCode.set(col.code, existing.id);
      summary.colorsReused++;
    } else {
      const [created] = await db.insert(colors).values({ machineId, code: col.code, name: col.name }).returning();
      colorIdByCode.set(col.code, created.id);
      summary.colorsCreated++;
    }
  }

  for (const item of extracted.items) {
    let partId: string;
    const existingNumber = await db
      .select({ partId: partNumbers.partId })
      .from(partNumbers)
      .where(eq(partNumbers.value, item.baseNumber))
      .get();
    if (existingNumber) {
      partId = existingNumber.partId;
      summary.partsReused++;
    } else {
      const [created] = await db.insert(parts).values({ nameRaw: item.partName }).returning();
      partId = created.id;
      summary.partsCreated++;
      await db.insert(partNumbers).values({ partId, value: item.baseNumber, kind: 'oem', isPrimary: true });
    }

    for (const variant of item.variants) {
      const colorId = colorIdByCode.get(variant.colorCode);
      if (!colorId) {
        summary.variantsSkipped++;
        continue;
      }
      const dup = await db
        .select({ id: partColorVariants.id })
        .from(partColorVariants)
        .where(and(eq(partColorVariants.partId, partId), eq(partColorVariants.colorId, colorId)))
        .get();
      if (dup) {
        summary.variantsSkipped++;
        continue;
      }
      await db.insert(partColorVariants).values({
        partId,
        colorId,
        suffixCode: variant.suffix,
        fullNumber: `${item.baseNumber}${variant.suffix}`,
      });
      summary.variantsCreated++;
    }
  }

  return summary;
}

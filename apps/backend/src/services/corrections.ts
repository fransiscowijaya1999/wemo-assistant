import { z } from 'zod';
import { and, eq, isNull, ne, sql } from 'drizzle-orm';
import type { Db } from '../db/client';
import { aliases, assemblyItems, partColorVariants, partNumbers, parts, partSubstitutes } from '../db/schema';

// Structured catalog-correction proposals. The admin assistant only RECORDS these
// (via propose_* tools); nothing is written until the admin approves and the
// /admin/corrections/apply route calls applyCorrection. This keeps the
// "never auto-change, human verifies" invariant on the write-capable side too.

const numberKind = z.enum(['oem', 'alternative', 'superseded', 'aftermarket', 'bulk']);
export type NumberKind = z.infer<typeof numberKind>;

export const renameProposal = z.object({
  type: z.literal('rename'),
  partId: z.string(),
  nameNormalized: z.string().nullable().optional(),
  category: z.string().nullable().optional(),
  notes: z.string().nullable().optional(),
});

export const addAliasProposal = z.object({
  type: z.literal('add_alias'),
  partId: z.string(),
  term: z.string(),
  lang: z.string().nullable().optional(),
});

export const addNumberProposal = z.object({
  type: z.literal('add_number'),
  partId: z.string(),
  value: z.string(),
  kind: numberKind.optional(),
  brand: z.string().nullable().optional(),
});

export const editNumberProposal = z.object({
  type: z.literal('edit_number'),
  partId: z.string(),
  value: z.string().describe('The existing part number to edit (located within the part).'),
  newValue: z.string().optional(),
  kind: numberKind.optional(),
  brand: z.string().nullable().optional(),
});

export const mergeProposal = z.object({
  type: z.literal('merge'),
  sourcePartId: z.string().describe('The DUPLICATE part to remove; everything it owns moves to the target.'),
  targetPartId: z.string().describe('The canonical part to KEEP.'),
});

export const substituteProposal = z.object({
  type: z.literal('substitute'),
  partId: z.string(),
  substitutePartId: z.string(),
  note: z.string().nullable().optional(),
});

export const correctionProposal = z.discriminatedUnion('type', [
  renameProposal,
  addAliasProposal,
  addNumberProposal,
  editNumberProposal,
  mergeProposal,
  substituteProposal,
]);
export type CorrectionProposal = z.infer<typeof correctionProposal>;

/** Live counts of what a source part owns — shown as a merge preview before applying. */
export async function mergePreview(db: Db, sourcePartId: string) {
  const one = async (table: typeof partNumbers | typeof aliases | typeof partColorVariants, col: 'partId') =>
    Number(
      (
        await db
          .select({ c: sql<number>`count(*)` })
          .from(table)
          .where(and(eq(table[col], sourcePartId), isNull(table.deletedAt)))
          .get()
      )?.c ?? 0,
    );
  const positions = Number(
    (
      await db
        .select({ c: sql<number>`count(*)` })
        .from(assemblyItems)
        .where(and(eq(assemblyItems.basePartId, sourcePartId), isNull(assemblyItems.deletedAt)))
        .get()
    )?.c ?? 0,
  );
  return {
    numbers: await one(partNumbers, 'partId'),
    aliases: await one(aliases, 'partId'),
    colorVariants: await one(partColorVariants, 'partId'),
    positions,
  };
}

class ApplyError extends Error {}

async function livepart(db: Db, partId: string) {
  const part = await db.select().from(parts).where(eq(parts.id, partId)).get();
  if (!part || part.deletedAt) throw new ApplyError('part not found');
  return part;
}

/**
 * Applies one approved correction. Throws ApplyError with a human message on any
 * guard failure (missing part, duplicate number, unknown number, empty edit).
 * Callers (the route) map that to a 400/409.
 */
export async function applyCorrection(db: Db, p: CorrectionProposal): Promise<{ summary: string }> {
  const now = new Date();
  switch (p.type) {
    case 'rename': {
      await livepart(db, p.partId);
      const set: Record<string, unknown> = { updatedAt: now };
      if (p.nameNormalized !== undefined) set.nameNormalized = p.nameNormalized;
      if (p.category !== undefined) set.category = p.category;
      if (p.notes !== undefined) set.notes = p.notes;
      if (Object.keys(set).length === 1) throw new ApplyError('nothing to change');
      await db.update(parts).set(set).where(eq(parts.id, p.partId));
      return { summary: `Renamed/updated part fields` };
    }
    case 'add_alias': {
      await livepart(db, p.partId);
      const term = p.term.trim();
      if (!term) throw new ApplyError('alias term is empty');
      const dup = await db
        .select({ id: aliases.id })
        .from(aliases)
        .where(and(eq(aliases.partId, p.partId), eq(aliases.term, term), isNull(aliases.deletedAt)))
        .get();
      if (dup) throw new ApplyError(`alias "${term}" already exists on this part`);
      await db.insert(aliases).values({ partId: p.partId, term, lang: p.lang ?? null });
      return { summary: `Added alias "${term}"` };
    }
    case 'add_number': {
      await livepart(db, p.partId);
      const value = p.value.trim();
      if (!value) throw new ApplyError('part number is empty');
      const taken = await db
        .select({ partId: partNumbers.partId })
        .from(partNumbers)
        .where(and(eq(partNumbers.value, value), isNull(partNumbers.deletedAt)))
        .get();
      if (taken) {
        throw new ApplyError(
          taken.partId === p.partId ? `number ${value} is already on this part` : `number ${value} already belongs to another part`,
        );
      }
      await db.insert(partNumbers).values({ partId: p.partId, value, kind: p.kind ?? 'oem', brand: p.brand ?? null });
      return { summary: `Added number ${value}` };
    }
    case 'edit_number': {
      await livepart(db, p.partId);
      const existing = await db
        .select()
        .from(partNumbers)
        .where(and(eq(partNumbers.partId, p.partId), eq(partNumbers.value, p.value), isNull(partNumbers.deletedAt)))
        .get();
      if (!existing) throw new ApplyError(`number ${p.value} not found on this part`);
      const set: Record<string, unknown> = { updatedAt: now };
      if (p.newValue !== undefined && p.newValue.trim() && p.newValue.trim() !== p.value) {
        const nv = p.newValue.trim();
        const clash = await db
          .select({ id: partNumbers.id })
          .from(partNumbers)
          .where(and(eq(partNumbers.value, nv), isNull(partNumbers.deletedAt), ne(partNumbers.id, existing.id)))
          .get();
        if (clash) throw new ApplyError(`number ${nv} already exists`);
        set.value = nv;
      }
      if (p.kind !== undefined) set.kind = p.kind;
      if (p.brand !== undefined) set.brand = p.brand;
      if (Object.keys(set).length === 1) throw new ApplyError('nothing to change');
      await db.update(partNumbers).set(set).where(eq(partNumbers.id, existing.id));
      return { summary: `Edited number ${p.value}` };
    }
    case 'merge': {
      if (p.sourcePartId === p.targetPartId) throw new ApplyError('cannot merge a part into itself');
      const src = await livepart(db, p.sourcePartId);
      await livepart(db, p.targetPartId);

      // part_numbers: reparent, dropping (soft-delete) any value the target already has.
      const tgtNums = await db
        .select({ value: partNumbers.value, isPrimary: partNumbers.isPrimary })
        .from(partNumbers)
        .where(and(eq(partNumbers.partId, p.targetPartId), isNull(partNumbers.deletedAt)));
      const tgtValues = new Set(tgtNums.map((n) => n.value));
      const tgtHasPrimary = tgtNums.some((n) => n.isPrimary);
      const srcNums = await db
        .select()
        .from(partNumbers)
        .where(and(eq(partNumbers.partId, p.sourcePartId), isNull(partNumbers.deletedAt)));
      let movedNumbers = 0;
      for (const n of srcNums) {
        if (tgtValues.has(n.value)) {
          await db.update(partNumbers).set({ deletedAt: now, updatedAt: now }).where(eq(partNumbers.id, n.id));
        } else {
          // Target keeps its own primary; demote moved numbers only if the target already has one.
          await db
            .update(partNumbers)
            .set({ partId: p.targetPartId, isPrimary: tgtHasPrimary ? false : n.isPrimary, updatedAt: now })
            .where(eq(partNumbers.id, n.id));
          movedNumbers++;
        }
      }

      // aliases: reparent, deduped by term. Also keep the source's name searchable as an alias.
      const tgtAliasRows = await db
        .select({ term: aliases.term })
        .from(aliases)
        .where(and(eq(aliases.partId, p.targetPartId), isNull(aliases.deletedAt)));
      const tgtTerms = new Set(tgtAliasRows.map((a) => a.term));
      const srcAliases = await db
        .select()
        .from(aliases)
        .where(and(eq(aliases.partId, p.sourcePartId), isNull(aliases.deletedAt)));
      let movedAliases = 0;
      for (const a of srcAliases) {
        if (tgtTerms.has(a.term)) {
          await db.update(aliases).set({ deletedAt: now, updatedAt: now }).where(eq(aliases.id, a.id));
        } else {
          await db.update(aliases).set({ partId: p.targetPartId, updatedAt: now }).where(eq(aliases.id, a.id));
          tgtTerms.add(a.term);
          movedAliases++;
        }
      }
      const srcName = src.nameNormalized ?? src.nameRaw;
      if (srcName && !tgtTerms.has(srcName)) {
        await db.insert(aliases).values({ partId: p.targetPartId, term: srcName });
      }

      // part_color_variants: reparent, deduped by color.
      const tgtCvRows = await db
        .select({ colorId: partColorVariants.colorId })
        .from(partColorVariants)
        .where(and(eq(partColorVariants.partId, p.targetPartId), isNull(partColorVariants.deletedAt)));
      const tgtColorIds = new Set(tgtCvRows.map((c) => c.colorId));
      const srcCv = await db
        .select()
        .from(partColorVariants)
        .where(and(eq(partColorVariants.partId, p.sourcePartId), isNull(partColorVariants.deletedAt)));
      let movedColors = 0;
      for (const cv of srcCv) {
        if (tgtColorIds.has(cv.colorId)) {
          await db.update(partColorVariants).set({ deletedAt: now, updatedAt: now }).where(eq(partColorVariants.id, cv.id));
        } else {
          await db.update(partColorVariants).set({ partId: p.targetPartId, updatedAt: now }).where(eq(partColorVariants.id, cv.id));
          movedColors++;
        }
      }

      // assembly_items: repoint diagram positions to the surviving part.
      const positionRows = await db
        .select({ id: assemblyItems.id })
        .from(assemblyItems)
        .where(and(eq(assemblyItems.basePartId, p.sourcePartId), isNull(assemblyItems.deletedAt)));
      for (const it of positionRows) {
        await db.update(assemblyItems).set({ basePartId: p.targetPartId, updatedAt: now }).where(eq(assemblyItems.id, it.id));
      }

      // Retire the duplicate part.
      await db.update(parts).set({ deletedAt: now, updatedAt: now }).where(eq(parts.id, p.sourcePartId));

      return {
        summary: `Merged: moved ${movedNumbers} numbers, ${movedAliases} aliases, ${movedColors} colors, ${positionRows.length} positions`,
      };
    }
    case 'substitute': {
      if (p.partId === p.substitutePartId) throw new ApplyError('cannot substitute a part for itself');
      await livepart(db, p.partId);
      await livepart(db, p.substitutePartId);

      const [minId, maxId] = p.partId < p.substitutePartId ? [p.partId, p.substitutePartId] : [p.substitutePartId, p.partId];
      const dup = await db
        .select({ id: partSubstitutes.id })
        .from(partSubstitutes)
        .where(and(eq(partSubstitutes.partId, minId), eq(partSubstitutes.substitutePartId, maxId), isNull(partSubstitutes.deletedAt)))
        .get();
      if (dup) throw new ApplyError('substitute link already exists');

      await db.insert(partSubstitutes).values({
        partId: minId,
        substitutePartId: maxId,
        note: p.note ?? null,
      });

      return { summary: `Linked as substitutes` };
    }
  }
}

export { ApplyError };

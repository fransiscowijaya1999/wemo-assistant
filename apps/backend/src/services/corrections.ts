import { z } from 'zod';
import { and, eq, isNull, ne } from 'drizzle-orm';
import type { Db } from '../db/client';
import { aliases, partNumbers, parts } from '../db/schema';

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

export const correctionProposal = z.discriminatedUnion('type', [
  renameProposal,
  addAliasProposal,
  addNumberProposal,
  editNumberProposal,
]);
export type CorrectionProposal = z.infer<typeof correctionProposal>;

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
  }
}

export { ApplyError };

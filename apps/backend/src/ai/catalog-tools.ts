import { and, eq, inArray, isNull, like, or } from 'drizzle-orm';
import type { Db } from '../db/client';
import {
  aliases,
  assemblies,
  assemblyItems,
  colors,
  itemResolutions,
  machines,
  machineVariants,
  partColorVariants,
  partNumbers,
  parts,
} from '../db/schema';
import type { ChatToolDef, Citation, ToolExecutor } from './chat';

// Read-only catalog lookups exposed to the clerk assistant. Every query is a
// SELECT filtered to live (non-soft-deleted) rows. No writes exist here.

const SEARCH_LIMIT = 25;

/** Part ids matching a single term (substring, case-insensitive) in any field. */
async function idsMatchingTerm(db: Db, term: string): Promise<Set<string>> {
  const pattern = `%${term}%`;
  const [byNumber, byName, byAlias] = await Promise.all([
    db
      .select({ partId: partNumbers.partId })
      .from(partNumbers)
      .where(and(like(partNumbers.value, pattern), isNull(partNumbers.deletedAt))),
    db
      .select({ partId: parts.id })
      .from(parts)
      .where(and(or(like(parts.nameNormalized, pattern), like(parts.nameRaw, pattern)), isNull(parts.deletedAt))),
    db
      .select({ partId: aliases.partId })
      .from(aliases)
      .where(and(like(aliases.term, pattern), isNull(aliases.deletedAt))),
  ]);
  return new Set([...byNumber, ...byName, ...byAlias].map((r) => r.partId));
}

async function searchParts(db: Db, query: string) {
  const q = query.trim();
  if (!q) return [];

  // Token search: rank parts by how many query words match ANY field, so extra
  // words the model tacks on (e.g. the motorcycle model) don't break the match.
  const tokens = [...new Set(q.toLowerCase().split(/\s+/).filter((t) => t.length >= 2))].slice(0, 8);
  const terms = tokens.length ? tokens : [q];

  const score = new Map<string, number>();
  for (const term of terms) {
    for (const id of await idsMatchingTerm(db, term)) {
      score.set(id, (score.get(id) ?? 0) + 1);
    }
  }
  if (!score.size) return [];

  // Highest token-match count first; then load names + a representative number.
  const ids = [...score.entries()].sort((a, b) => b[1] - a[1]).slice(0, SEARCH_LIMIT).map((e) => e[0]);

  const [partRows, numberRows] = await Promise.all([
    db.select().from(parts).where(inArray(parts.id, ids)),
    db.select().from(partNumbers).where(and(inArray(partNumbers.partId, ids), isNull(partNumbers.deletedAt))),
  ]);

  const partById = new Map(partRows.map((p) => [p.id, p]));
  const primary = new Map<string, string>();
  const any = new Map<string, string>();
  for (const n of numberRows) {
    if (!any.has(n.partId)) any.set(n.partId, n.value);
    if (n.isPrimary && !primary.has(n.partId)) primary.set(n.partId, n.value);
  }

  // Preserve the ranked order from `ids`.
  return ids
    .map((id) => partById.get(id))
    .filter((p): p is NonNullable<typeof p> => !!p)
    .map((p) => ({
      partId: p.id,
      name: p.nameNormalized ?? p.nameRaw,
      primaryNumber: primary.get(p.id) ?? any.get(p.id) ?? null,
    }));
}

async function getPart(db: Db, args: { partId?: string; number?: string }) {
  let id = args.partId;
  if (!id && args.number) {
    const pn = await db
      .select({ partId: partNumbers.partId })
      .from(partNumbers)
      .where(and(eq(partNumbers.value, args.number), isNull(partNumbers.deletedAt)))
      .get();
    id = pn?.partId;
  }
  if (!id) return null;

  const part = await db.select().from(parts).where(eq(parts.id, id)).get();
  if (!part || part.deletedAt) return null;

  const [numberRows, colorRows, aliasRows, placementRows] = await Promise.all([
    db.select().from(partNumbers).where(and(eq(partNumbers.partId, id), isNull(partNumbers.deletedAt))),
    db
      .select({
        fullNumber: partColorVariants.fullNumber,
        suffix: partColorVariants.suffixCode,
        colorCode: colors.code,
        colorName: colors.name,
      })
      .from(partColorVariants)
      .innerJoin(colors, eq(colors.id, partColorVariants.colorId))
      .where(and(eq(partColorVariants.partId, id), isNull(partColorVariants.deletedAt))),
    db.select().from(aliases).where(and(eq(aliases.partId, id), isNull(aliases.deletedAt))),
    db
      .select({
        itemId: assemblyItems.id,
        refNo: assemblyItems.refNo,
        assemblyCode: assemblies.code,
        assemblyName: assemblies.name,
        brand: machines.brand,
        model: machines.model,
      })
      .from(assemblyItems)
      .innerJoin(assemblies, eq(assemblies.id, assemblyItems.assemblyId))
      .innerJoin(machines, eq(machines.id, assemblies.machineId))
      .where(and(eq(assemblyItems.basePartId, id), isNull(assemblyItems.deletedAt), isNull(assemblies.deletedAt))),
  ]);

  // Applicability per position: which number/variant/serial range applies there.
  const numberIds = numberRows.map((n) => n.id);
  const numberValueById = new Map(numberRows.map((n) => [n.id, n.value]));
  const resolutionRows = numberIds.length
    ? await db
        .select({
          assemblyItemId: itemResolutions.assemblyItemId,
          partNumberId: itemResolutions.partNumberId,
          qty: itemResolutions.qty,
          variantName: machineVariants.name,
          serialFrom: itemResolutions.serialFrom,
          serialTo: itemResolutions.serialTo,
        })
        .from(itemResolutions)
        .leftJoin(machineVariants, eq(machineVariants.id, itemResolutions.variantId))
        .where(and(inArray(itemResolutions.partNumberId, numberIds), isNull(itemResolutions.deletedAt)))
    : [];
  const applicabilityByItem = new Map<string, {
    number: string | null;
    qty: number;
    variant: string | null;
    serialFrom: string | null;
    serialTo: string | null;
  }[]>();
  for (const r of resolutionRows) {
    const arr = applicabilityByItem.get(r.assemblyItemId) ?? [];
    arr.push({
      number: numberValueById.get(r.partNumberId) ?? null,
      qty: r.qty,
      variant: r.variantName,
      serialFrom: r.serialFrom,
      serialTo: r.serialTo,
    });
    applicabilityByItem.set(r.assemblyItemId, arr);
  }

  const primaryNumber =
    numberRows.find((n) => n.isPrimary)?.value ?? numberRows[0]?.value ?? null;

  return {
    id: part.id,
    name: part.nameNormalized ?? part.nameRaw,
    category: part.category,
    notes: part.notes,
    primaryNumber,
    numbers: numberRows.map((n) => ({ value: n.value, kind: n.kind, brand: n.brand, isPrimary: n.isPrimary })),
    colorVariants: colorRows.map((c) => ({
      fullNumber: c.fullNumber,
      suffix: c.suffix,
      colorCode: c.colorCode,
      colorName: c.colorName,
    })),
    aliases: aliasRows.map((a) => a.term),
    appearsIn: placementRows.map((p) => ({
      refNo: p.refNo,
      assembly: `${p.assemblyCode} ${p.assemblyName}`,
      machine: `${p.brand} ${p.model}`,
      applicability: applicabilityByItem.get(p.itemId) ?? [],
    })),
  };
}

export const CATALOG_TOOL_DEFS: ChatToolDef[] = [
  {
    name: 'search_parts',
    description:
      'Search the parts catalog by part number (OEM / alternate / superseded / aftermarket), part name, or a local/colloquial term (Indonesian or English). Returns candidate canonical parts with a primary number, best matches first. Use this first to find a part. Keep the query SHORT — a part number or a couple of keywords (e.g. "head gasket" or "paking kepala"). Do NOT include the motorcycle model/brand in the query; results are ranked by how many of your words match.',
    input_schema: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'A part number, or a few keywords from the part name/term. No motorcycle model.',
        },
      },
      required: ['query'],
    },
  },
  {
    name: 'get_part',
    description:
      'Get full detail for one canonical part: all interchangeable numbers (kind/brand), per-color full numbers, aliases, and the diagram positions/machines it appears on. Each position includes `applicability`: which exact number, quantity, variant (e.g. STD/ABS) and frame-serial range (serialFrom/serialTo, null = unbounded; variant null = all variants) applies there — use it to answer "which exact number/qty for THIS bike (variant + frame serial)". Identify the part by `partId` (from search_parts) or by any `number` belonging to it.',
    input_schema: {
      type: 'object',
      properties: {
        partId: { type: 'string', description: 'Canonical part id from search_parts.' },
        number: { type: 'string', description: 'Any part number belonging to the part.' },
      },
    },
  },
];

/** Bundles the tool executor with a citation collector for one chat turn. */
export function createCatalogToolset(db: Db): {
  defs: ChatToolDef[];
  execute: ToolExecutor;
  citations: () => Citation[];
} {
  const cited = new Map<string, Citation>();

  const execute: ToolExecutor = async (name, input) => {
    switch (name) {
      case 'search_parts': {
        const results = await searchParts(db, String(input.query ?? ''));
        for (const r of results) cited.set(r.partId, r);
        return { results };
      }
      case 'get_part': {
        const part = await getPart(db, {
          partId: input.partId ? String(input.partId) : undefined,
          number: input.number ? String(input.number) : undefined,
        });
        if (part) cited.set(part.id, { partId: part.id, name: part.name, primaryNumber: part.primaryNumber });
        return part ?? { error: 'not found' };
      }
      default:
        return { error: `unknown tool: ${name}` };
    }
  };

  return { defs: CATALOG_TOOL_DEFS, execute, citations: () => [...cited.values()] };
}

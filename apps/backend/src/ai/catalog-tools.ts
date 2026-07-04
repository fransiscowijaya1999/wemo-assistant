import { and, eq, inArray, isNull, like, or, sql } from 'drizzle-orm';
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

/** Part ids matching a single term (substring, case-insensitive) in any field.
 * Part numbers also match with separators stripped, so a partial number typed
 * without dashes ("31928MFF" or "31928") still resolves. */
async function idsMatchingTerm(db: Db, term: string): Promise<Set<string>> {
  const pattern = `%${term}%`;
  const condensed = term.replace(/[^0-9a-z]/gi, '');
  const numberMatch = condensed
    ? or(
        like(partNumbers.value, pattern),
        like(sql`replace(${partNumbers.value}, '-', '')`, `%${condensed}%`),
      )
    : like(partNumbers.value, pattern);
  const [byNumber, byName, byAlias] = await Promise.all([
    db
      .select({ partId: partNumbers.partId })
      .from(partNumbers)
      .where(and(numberMatch, isNull(partNumbers.deletedAt))),
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

export async function searchParts(db: Db, query: string) {
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

export async function getPart(db: Db, args: { partId?: string; number?: string }) {
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

/** All live machines with how many live assemblies each has. Ground truth for
 * "what machines/models do I have". */
export async function listMachines(db: Db) {
  const rows = await db
    .select({ id: machines.id, brand: machines.brand, model: machines.model })
    .from(machines)
    .where(isNull(machines.deletedAt));
  const counts = await db
    .select({ machineId: assemblies.machineId, c: sql<number>`count(*)` })
    .from(assemblies)
    .where(isNull(assemblies.deletedAt))
    .groupBy(assemblies.machineId);
  const cmap = new Map(counts.map((r) => [r.machineId, Number(r.c)]));
  return rows
    .map((m) => ({ id: m.id, name: `${m.brand} ${m.model}`, assemblyCount: cmap.get(m.id) ?? 0 }))
    .sort((a, b) => a.name.localeCompare(b.name));
}

/** Live assemblies for one machine, identified by id or by name (brand+model,
 * case-insensitive substring). Ground truth for "what assemblies does X have". */
export async function listAssemblies(db: Db, args: { machineId?: string; machine?: string }) {
  const all = await db
    .select({ id: machines.id, brand: machines.brand, model: machines.model })
    .from(machines)
    .where(isNull(machines.deletedAt));
  let target = args.machineId ? all.find((m) => m.id === args.machineId) : undefined;
  if (!target && args.machine) {
    const q = args.machine.trim().toLowerCase();
    target = all.find((m) => `${m.brand} ${m.model}`.toLowerCase().includes(q));
  }
  if (!target) {
    return { error: 'machine not found', availableMachines: all.map((m) => `${m.brand} ${m.model}`) };
  }
  const rows = await db
    .select({ code: assemblies.code, name: assemblies.name, groupType: assemblies.groupType })
    .from(assemblies)
    .where(and(eq(assemblies.machineId, target.id), isNull(assemblies.deletedAt)));
  return {
    machine: `${target.brand} ${target.model}`,
    assemblies: rows.map((r) => ({ code: r.code, name: r.name, group: r.groupType })),
  };
}

/** The parts listed in one assembly (by assemblyId, or machine name + code).
 * Ground truth for "what parts are in <assembly>" — e.g. the valves in CAMSHAFT/VALVE. */
export async function getAssembly(db: Db, args: { assemblyId?: string; machine?: string; code?: string }) {
  let matched: { id: string; code: string; name: string; machine: string }[] = [];
  if (args.assemblyId) {
    const a = await db
      .select({ id: assemblies.id, code: assemblies.code, name: assemblies.name, brand: machines.brand, model: machines.model })
      .from(assemblies)
      .innerJoin(machines, eq(machines.id, assemblies.machineId))
      .where(and(eq(assemblies.id, args.assemblyId), isNull(assemblies.deletedAt)))
      .get();
    if (a) matched = [{ id: a.id, code: a.code, name: a.name, machine: `${a.brand} ${a.model}` }];
  } else if (args.code) {
    const rows = await db
      .select({ id: assemblies.id, code: assemblies.code, name: assemblies.name, brand: machines.brand, model: machines.model })
      .from(assemblies)
      .innerJoin(machines, eq(machines.id, assemblies.machineId))
      .where(isNull(assemblies.deletedAt));
    const code = args.code.trim().toLowerCase();
    const mq = args.machine?.trim().toLowerCase();
    matched = rows
      .filter((r) => r.code.toLowerCase() === code && (!mq || `${r.brand} ${r.model}`.toLowerCase().includes(mq)))
      .map((r) => ({ id: r.id, code: r.code, name: r.name, machine: `${r.brand} ${r.model}` }));
  }
  if (!matched.length) return { error: 'assembly not found' };

  // Union items across any assemblies that share this machine+code (continuation pages), by ref.
  const ids = matched.map((m) => m.id);
  const items = await db
    .select({
      refNo: assemblyItems.refNo,
      partId: assemblyItems.basePartId,
      nameRaw: parts.nameRaw,
      nameNormalized: parts.nameNormalized,
    })
    .from(assemblyItems)
    .leftJoin(parts, eq(parts.id, assemblyItems.basePartId))
    .where(and(inArray(assemblyItems.assemblyId, ids), isNull(assemblyItems.deletedAt)));

  const partIds = items.map((i) => i.partId).filter((x): x is string => !!x);
  const numRows = partIds.length
    ? await db
        .select({ partId: partNumbers.partId, value: partNumbers.value, isPrimary: partNumbers.isPrimary })
        .from(partNumbers)
        .where(and(inArray(partNumbers.partId, partIds), isNull(partNumbers.deletedAt)))
    : [];
  const primary = new Map<string, string>();
  const anyNum = new Map<string, string>();
  for (const n of numRows) {
    if (!anyNum.has(n.partId)) anyNum.set(n.partId, n.value);
    if (n.isPrimary && !primary.has(n.partId)) primary.set(n.partId, n.value);
  }

  const byRef = new Map<string, { refNo: string; partId: string | null; name: string | null; number: string | null }>();
  for (const it of items) {
    if (byRef.has(it.refNo)) continue;
    byRef.set(it.refNo, {
      refNo: it.refNo,
      partId: it.partId,
      name: it.nameNormalized ?? it.nameRaw ?? null,
      number: it.partId ? primary.get(it.partId) ?? anyNum.get(it.partId) ?? null : null,
    });
  }
  const sorted = [...byRef.values()].sort((a, b) => {
    const na = Number(a.refNo);
    const nb = Number(b.refNo);
    if (!Number.isNaN(na) && !Number.isNaN(nb)) return na - nb;
    return a.refNo.localeCompare(b.refNo);
  });
  return { machine: matched[0].machine, assembly: { code: matched[0].code, name: matched[0].name }, items: sorted };
}

const LISTING_TOOL_DEFS: ChatToolDef[] = [
  {
    name: 'list_machines',
    description:
      'List ALL machines (motorcycle models) in the catalog, each with how many assemblies it has. Use this FIRST to answer "what machines/models do I have" or before claiming a model is or is not in the catalog — never guess a model\'s presence from part searches.',
    input_schema: { type: 'object', properties: {} },
  },
  {
    name: 'list_assemblies',
    description:
      'List the assembly/diagram groups (code + name) for ONE machine. Identify the machine by `machineId` (from list_machines) or by `machine` name (e.g. "PCX160"). Use this to answer "what assemblies/diagrams does <model> have".',
    input_schema: {
      type: 'object',
      properties: {
        machineId: { type: 'string', description: 'Machine id from list_machines.' },
        machine: { type: 'string', description: 'Machine name/model, e.g. "PCX160" or "BeAT".' },
      },
    },
  },
  {
    name: 'get_assembly',
    description:
      'List the PARTS in one assembly (each ref number → part name + primary number). Identify it by `assemblyId`, or by `machine` name + assembly `code` (e.g. machine "PCX160", code "E-4"). Use this to answer "what parts are in <assembly>" and to check whether a specific part (e.g. a valve / "klep") is present — assembly names like "CAMSHAFT/VALVE" tell you which assembly to open. Do NOT conclude a part is absent from a machine without opening its relevant assembly here.',
    input_schema: {
      type: 'object',
      properties: {
        assemblyId: { type: 'string', description: 'Assembly id, if known.' },
        machine: { type: 'string', description: 'Machine name/model, e.g. "PCX160".' },
        code: { type: 'string', description: 'Assembly code, e.g. "E-4".' },
      },
    },
  },
];

export const CATALOG_TOOL_DEFS: ChatToolDef[] = [
  {
    name: 'search_parts',
    description:
      'Search the parts catalog by part number (OEM / alternate / superseded / aftermarket), part name, or a local/colloquial term (Indonesian or English). Part numbers match even when PARTIAL or typed without dashes ("31928MFF" finds 31928-MFF-D01). Returns candidate canonical parts with a primary number, best matches first. Use this first to find a part. Keep the query SHORT — a part number or a couple of keywords (e.g. "head gasket" or "paking kepala"). Do NOT include the motorcycle model/brand in the query; results are ranked by how many of your words match.',
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
  ...LISTING_TOOL_DEFS,
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
      case 'list_machines':
        return { machines: await listMachines(db) };
      case 'list_assemblies':
        return await listAssemblies(db, {
          machineId: input.machineId ? String(input.machineId) : undefined,
          machine: input.machine ? String(input.machine) : undefined,
        });
      case 'get_assembly':
        return await getAssembly(db, {
          assemblyId: input.assemblyId ? String(input.assemblyId) : undefined,
          machine: input.machine ? String(input.machine) : undefined,
          code: input.code ? String(input.code) : undefined,
        });
      default:
        return { error: `unknown tool: ${name}` };
    }
  };

  return { defs: CATALOG_TOOL_DEFS, execute, citations: () => [...cited.values()] };
}

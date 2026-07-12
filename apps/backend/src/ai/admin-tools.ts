import { and, eq, isNull } from 'drizzle-orm';
import type { Db } from '../db/client';
import { partNumbers, parts } from '../db/schema';
import type { ChatToolDef, ToolExecutor } from './chat';
import { getAssembly, getPart, listAssemblies, listMachines, searchParts } from './catalog-tools';
import { mergePreview } from '../services/corrections';
import type { CorrectionProposal, NumberKind } from '../services/corrections';

// ADMIN-facing assistant toolset. Unlike the clerk toolset, the admin may correct
// the catalog — BUT the assistant still never writes. The propose_* tools only
// RECORD a structured proposal (with a before/after snapshot for the review card);
// the write happens later, in /admin/corrections/apply, only after the admin
// approves. Read tools (search_parts/get_part) are shared with the clerk side.

/** One recorded proposal: the apply payload plus display-only context for the UI card. */
export interface Proposal {
  id: string;
  proposal: CorrectionProposal;
  summary: string;
  partLabel: string;
  before?: Record<string, unknown>;
  after?: Record<string, unknown>;
}

async function partLabel(db: Db, partId: string): Promise<string> {
  const part = await db.select().from(parts).where(eq(parts.id, partId)).get();
  if (!part) return partId;
  const num = await db
    .select({ value: partNumbers.value, isPrimary: partNumbers.isPrimary })
    .from(partNumbers)
    .where(and(eq(partNumbers.partId, partId), isNull(partNumbers.deletedAt)));
  const primary = num.find((n) => n.isPrimary)?.value ?? num[0]?.value;
  const name = part.nameNormalized ?? part.nameRaw;
  return primary ? `${name} (${primary})` : name;
}

const READ_TOOL_DEFS: ChatToolDef[] = [
  {
    name: 'list_machines',
    description:
      'List ALL machines (motorcycle models) in the catalog, each with how many assemblies it has. Use this FIRST to answer "what machines/models do I have" or before claiming a model is or is not present — never guess a model\'s presence from part searches.',
    input_schema: { type: 'object', properties: {} },
  },
  {
    name: 'list_assemblies',
    description:
      'List the assembly/diagram groups (code + name) for ONE machine, identified by `machineId` (from list_machines) or by `machine` name (e.g. "PCX160"). Use to answer "what assemblies/diagrams does <model> have".',
    input_schema: {
      type: 'object',
      properties: {
        machineId: { type: 'string', description: 'Machine id from list_machines.' },
        machine: { type: 'string', description: 'Machine name/model, e.g. "PCX160".' },
      },
    },
  },
  {
    name: 'get_assembly',
    description:
      'List the PARTS in one assembly (each ref number → part name + primary number). Identify by `assemblyId`, or `machine` name + assembly `code` (e.g. "PCX160" + "E-4"). Use to answer "what parts are in <assembly>" and to check whether a part (e.g. a valve / "klep") is present before proposing to add it. Do NOT conclude a part is absent without opening the relevant assembly here (its name, e.g. "CAMSHAFT/VALVE", tells you which).',
    input_schema: {
      type: 'object',
      properties: {
        assemblyId: { type: 'string', description: 'Assembly id, if known.' },
        machine: { type: 'string', description: 'Machine name/model, e.g. "PCX160".' },
        code: { type: 'string', description: 'Assembly code, e.g. "E-4".' },
      },
    },
  },
  {
    name: 'search_parts',
    description:
      'Search the catalog by part number, name, or a local/colloquial term (Indonesian or English). Part numbers match even when partial or typed without dashes. Returns candidate canonical parts with a primary number. Use this to find the part you want to correct. Keep the query short.',
    input_schema: {
      type: 'object',
      properties: { query: { type: 'string', description: 'A part number or a few keywords.' } },
      required: ['query'],
    },
  },
  {
    name: 'get_part',
    description:
      'Get full detail for one canonical part before proposing a correction: canonical name, category, notes, all interchangeable numbers (value/kind/brand), per-color numbers, aliases, and where it appears. Identify by partId (from search_parts) or by any number.',
    input_schema: {
      type: 'object',
      properties: {
        partId: { type: 'string', description: 'Canonical part id from search_parts.' },
        number: { type: 'string', description: 'Any part number belonging to the part.' },
      },
    },
  },
];

const PROPOSE_TOOL_DEFS: ChatToolDef[] = [
  {
    name: 'propose_rename',
    description:
      'Propose normalizing/correcting a part\'s descriptive fields. Use to turn a raw catalog name like "GASKET, CYLINDER HEAD" into a clean "Cylinder Head Gasket", set a category, or fix notes. Only include the fields you want to change. Nothing is applied until the admin approves.',
    input_schema: {
      type: 'object',
      properties: {
        partId: { type: 'string' },
        nameNormalized: { type: 'string', description: 'Clean, human-friendly canonical name.' },
        category: { type: 'string' },
        notes: { type: 'string' },
      },
      required: ['partId'],
    },
  },
  {
    name: 'propose_add_alias',
    description:
      'Propose adding a search alias / colloquial name (often Indonesian, e.g. "paking kepala" for a cylinder-head gasket) so clerks can find the part by everyday words. One term per call.',
    input_schema: {
      type: 'object',
      properties: {
        partId: { type: 'string' },
        term: { type: 'string', description: 'The alias/colloquial term.' },
        lang: { type: 'string', description: '"id" or "en".' },
      },
      required: ['partId', 'term'],
    },
  },
  {
    name: 'propose_add_number',
    description:
      'Propose adding an interchangeable / alternate / superseded / aftermarket part number to a part. Use for a number the part should carry but does not yet.',
    input_schema: {
      type: 'object',
      properties: {
        partId: { type: 'string' },
        value: { type: 'string', description: 'The part number, e.g. 12200-KVY-900.' },
        kind: { type: 'string', enum: ['oem', 'alternative', 'superseded', 'aftermarket', 'bulk'] },
        brand: { type: 'string', description: 'Brand if relevant, e.g. NGK.' },
      },
      required: ['partId', 'value'],
    },
  },
  {
    name: 'propose_edit_number',
    description:
      'Propose correcting an EXISTING number on a part: fix a typo (newValue), or retag its kind/brand. Locate the number by its current value.',
    input_schema: {
      type: 'object',
      properties: {
        partId: { type: 'string' },
        value: { type: 'string', description: 'The current (existing) number to edit.' },
        newValue: { type: 'string', description: 'Corrected number, if fixing a typo.' },
        kind: { type: 'string', enum: ['oem', 'alternative', 'superseded', 'aftermarket', 'bulk'] },
        brand: { type: 'string' },
      },
      required: ['partId', 'value'],
    },
  },
  {
    name: 'propose_merge',
    description:
      'Propose MERGING two duplicate canonical parts that are really the same physical part (e.g. the same part catalogued twice, or interchangeable numbers that should live on one part). Everything the SOURCE owns — all part numbers, aliases, color variants, and diagram positions — moves to the TARGET (the canonical part to keep), and the source is retired. Look up BOTH parts (search_parts/get_part) and be confident they are the same before proposing. Pick the target as the better-named / more complete part. NEVER merge unless the admin asked or clearly confirmed the two are identical.',
    input_schema: {
      type: 'object',
      properties: {
        sourcePartId: { type: 'string', description: 'The duplicate part to remove (its data moves to the target).' },
        targetPartId: { type: 'string', description: 'The canonical part to keep.' },
      },
      required: ['sourcePartId', 'targetPartId'],
    },
  },
  {
    name: 'propose_substitute',
    description:
      'Propose creating a manual interchange link (substitute) between two DIFFERENT canonical parts that can replace each other. Use this when the admin asks to link two separate parts as substitutes for each other.',
    input_schema: {
      type: 'object',
      properties: {
        partId: { type: 'string', description: 'The first canonical part ID.' },
        substitutePartId: { type: 'string', description: 'The second canonical part ID.' },
        note: { type: 'string', description: 'Optional note explaining the substitute relationship.' },
      },
      required: ['partId', 'substitutePartId'],
    },
  },
];

export const ADMIN_TOOL_DEFS: ChatToolDef[] = [...READ_TOOL_DEFS, ...PROPOSE_TOOL_DEFS];

/** Bundles the admin tool executor with a proposal collector for one chat turn. */
export function createAdminToolset(db: Db): {
  defs: ChatToolDef[];
  execute: ToolExecutor;
  proposals: () => Proposal[];
} {
  const drafts: Proposal[] = [];

  function record(proposal: CorrectionProposal, label: string, summary: string, before?: Record<string, unknown>, after?: Record<string, unknown>) {
    const p: Proposal = { id: crypto.randomUUID(), proposal, summary, partLabel: label, before, after };
    drafts.push(p);
    return { ok: true, proposalId: p.id, note: 'Recorded as a proposal for the admin to review and approve. Not applied yet.' };
  }

  const str = (v: unknown) => (v === undefined || v === null ? undefined : String(v));

  const execute: ToolExecutor = async (name, input) => {
    switch (name) {
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
      case 'search_parts':
        return { results: await searchParts(db, String(input.query ?? '')) };
      case 'get_part':
        return (
          (await getPart(db, {
            partId: input.partId ? String(input.partId) : undefined,
            number: input.number ? String(input.number) : undefined,
          })) ?? { error: 'not found' }
        );
      case 'propose_rename': {
        const partId = String(input.partId ?? '');
        if (!partId) return { error: 'partId is required' };
        const cur = await db.select().from(parts).where(eq(parts.id, partId)).get();
        if (!cur) return { error: 'part not found' };
        const proposal: CorrectionProposal = { type: 'rename', partId };
        const after: Record<string, unknown> = {};
        const before: Record<string, unknown> = {};
        for (const f of ['nameNormalized', 'category', 'notes'] as const) {
          if (input[f] !== undefined) {
            proposal[f] = str(input[f]);
            before[f] = cur[f] ?? null;
            after[f] = str(input[f]);
          }
        }
        if (!Object.keys(after).length) return { error: 'no fields to change' };
        return record(proposal, await partLabel(db, partId), 'Update part fields', before, after);
      }
      case 'propose_add_alias': {
        const partId = String(input.partId ?? '');
        const term = str(input.term);
        if (!partId || !term) return { error: 'partId and term are required' };
        if (!(await db.select({ id: parts.id }).from(parts).where(eq(parts.id, partId)).get())) return { error: 'part not found' };
        return record({ type: 'add_alias', partId, term, lang: str(input.lang) ?? null }, await partLabel(db, partId), `Add alias "${term}"`, undefined, { term });
      }
      case 'propose_add_number': {
        const partId = String(input.partId ?? '');
        const value = str(input.value);
        if (!partId || !value) return { error: 'partId and value are required' };
        if (!(await db.select({ id: parts.id }).from(parts).where(eq(parts.id, partId)).get())) return { error: 'part not found' };
        return record(
          { type: 'add_number', partId, value, kind: str(input.kind) as NumberKind | undefined, brand: str(input.brand) ?? null },
          await partLabel(db, partId),
          `Add number ${value}`,
          undefined,
          { value, kind: str(input.kind) ?? 'oem', brand: str(input.brand) ?? null },
        );
      }
      case 'propose_edit_number': {
        const partId = String(input.partId ?? '');
        const value = str(input.value);
        if (!partId || !value) return { error: 'partId and value are required' };
        const existing = await db
          .select()
          .from(partNumbers)
          .where(and(eq(partNumbers.partId, partId), eq(partNumbers.value, value), isNull(partNumbers.deletedAt)))
          .get();
        if (!existing) return { error: `number ${value} not found on this part` };
        const proposal: CorrectionProposal = { type: 'edit_number', partId, value };
        const after: Record<string, unknown> = {};
        const before: Record<string, unknown> = { value: existing.value, kind: existing.kind, brand: existing.brand };
        if (input.newValue !== undefined) {
          proposal.newValue = str(input.newValue);
          after.value = str(input.newValue);
        }
        if (input.kind !== undefined) {
          proposal.kind = str(input.kind) as typeof proposal.kind;
          after.kind = str(input.kind);
        }
        if (input.brand !== undefined) {
          proposal.brand = str(input.brand) ?? null;
          after.brand = str(input.brand) ?? null;
        }
        if (!Object.keys(after).length) return { error: 'no fields to change' };
        return record(proposal, await partLabel(db, partId), `Edit number ${value}`, before, after);
      }
      case 'propose_merge': {
        const sourcePartId = String(input.sourcePartId ?? '');
        const targetPartId = String(input.targetPartId ?? '');
        if (!sourcePartId || !targetPartId) return { error: 'sourcePartId and targetPartId are required' };
        if (sourcePartId === targetPartId) return { error: 'cannot merge a part into itself' };
        const [srcRow, tgtRow] = await Promise.all([
          db.select({ id: parts.id }).from(parts).where(and(eq(parts.id, sourcePartId), isNull(parts.deletedAt))).get(),
          db.select({ id: parts.id }).from(parts).where(and(eq(parts.id, targetPartId), isNull(parts.deletedAt))).get(),
        ]);
        if (!srcRow) return { error: 'source part not found' };
        if (!tgtRow) return { error: 'target part not found' };
        const [sourceLabel, targetLabel, preview] = await Promise.all([
          partLabel(db, sourcePartId),
          partLabel(db, targetPartId),
          mergePreview(db, sourcePartId),
        ]);
        return record(
          { type: 'merge', sourcePartId, targetPartId },
          `${sourceLabel}  →  ${targetLabel}`,
          `Merge duplicate into ${targetLabel}`,
          { remove: sourceLabel },
          {
            keep: targetLabel,
            moves: `${preview.numbers} numbers, ${preview.aliases} aliases, ${preview.colorVariants} colors, ${preview.positions} positions`,
          },
        );
      }
      case 'propose_substitute': {
        const partId = String(input.partId ?? '');
        const substitutePartId = String(input.substitutePartId ?? '');
        if (!partId || !substitutePartId) return { error: 'partId and substitutePartId are required' };
        if (partId === substitutePartId) return { error: 'cannot substitute a part for itself' };
        const [p1, p2] = await Promise.all([
          db.select({ id: parts.id }).from(parts).where(and(eq(parts.id, partId), isNull(parts.deletedAt))).get(),
          db.select({ id: parts.id }).from(parts).where(and(eq(parts.id, substitutePartId), isNull(parts.deletedAt))).get(),
        ]);
        if (!p1) return { error: 'partId not found' };
        if (!p2) return { error: 'substitutePartId not found' };
        
        const [label1, label2] = await Promise.all([
          partLabel(db, partId),
          partLabel(db, substitutePartId),
        ]);
        
        const note = str(input.note);
        return record(
          { type: 'substitute', partId, substitutePartId, note: note ?? null },
          `${label1}  ↔  ${label2}`,
          `Link as substitutes`,
          undefined,
          { note: note ?? '(no note)' }
        );
      }
      default:
        return { error: `unknown tool: ${name}` };
    }
  };

  return { defs: ADMIN_TOOL_DEFS, execute, proposals: () => drafts };
}

import { and, eq, isNull } from 'drizzle-orm';
import type { Db } from '../db/client';
import { partNumbers, parts } from '../db/schema';
import type { ChatToolDef, ToolExecutor } from './chat';
import { getAssembly, getPart, listAssemblies, listMachines, searchParts } from './catalog-tools';
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
];

export const ADMIN_TOOL_DEFS: ChatToolDef[] = [...READ_TOOL_DEFS, ...PROPOSE_TOOL_DEFS];

/** Bundles the admin tool executor with a proposal collector for one chat turn. */
export function createAdminToolset(db: Db): {
  defs: ChatToolDef[];
  execute: ToolExecutor;
  proposals: () => Proposal[];
} {
  const drafts: Proposal[] = [];

  async function record(proposal: CorrectionProposal, summary: string, before?: Record<string, unknown>, after?: Record<string, unknown>) {
    const p: Proposal = { id: crypto.randomUUID(), proposal, summary, partLabel: await partLabel(db, proposal.partId), before, after };
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
        return record(proposal, 'Update part fields', before, after);
      }
      case 'propose_add_alias': {
        const partId = String(input.partId ?? '');
        const term = str(input.term);
        if (!partId || !term) return { error: 'partId and term are required' };
        return record({ type: 'add_alias', partId, term, lang: str(input.lang) ?? null }, `Add alias "${term}"`, undefined, { term });
      }
      case 'propose_add_number': {
        const partId = String(input.partId ?? '');
        const value = str(input.value);
        if (!partId || !value) return { error: 'partId and value are required' };
        return record(
          { type: 'add_number', partId, value, kind: str(input.kind) as NumberKind | undefined, brand: str(input.brand) ?? null },
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
        return record(proposal, `Edit number ${value}`, before, after);
      }
      default:
        return { error: `unknown tool: ${name}` };
    }
  };

  return { defs: ADMIN_TOOL_DEFS, execute, proposals: () => drafts };
}

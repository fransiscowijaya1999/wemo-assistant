import type {
  AiSettings,
  Assembly,
  ColorCommitSummary,
  CommitSummary,
  EditorDot,
  ExtractedColorPage,
  ExtractedPage,
  FullAssembly,
  Machine,
  MachineVariant,
  PartFull,
  SearchResult,
} from './types';

const BASE = '/api';

export function getToken(): string {
  return localStorage.getItem('adminToken') ?? '';
}
export function setToken(t: string): void {
  localStorage.setItem('adminToken', t);
}

type ReqOpts = { method?: string; admin?: boolean; body?: unknown };

async function req<T>(path: string, opts: ReqOpts = {}): Promise<T> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (opts.admin) headers['Authorization'] = `Bearer ${getToken()}`;
  const res = await fetch(BASE + path, {
    method: opts.method ?? 'GET',
    headers,
    body: opts.body !== undefined ? JSON.stringify(opts.body) : undefined,
  });
  const text = await res.text();
  const data = text ? JSON.parse(text) : null;
  if (!res.ok) throw new Error(data?.error ?? res.statusText);
  return data as T;
}

export const imageUrl = (assemblyId: string) => `${BASE}/assemblies/${assemblyId}/image`;

export const api = {
  listMachines: () => req<Machine[]>('/machines'),
  createMachine: (m: { brand: string; model: string }) =>
    req<Machine>('/machines', { method: 'POST', admin: true, body: m }),
  ingestPage: (imageBase64: string, mediaType: string) =>
    req<{ extracted: ExtractedPage }>('/ingest/page', {
      method: 'POST',
      admin: true,
      body: { imageBase64, mediaType },
    }),
  commitPage: (machineId: string, groupType: string, extracted: ExtractedPage) =>
    req<{ ok: boolean; summary: CommitSummary }>('/ingest/commit', {
      method: 'POST',
      admin: true,
      body: { machineId, groupType, extracted },
    }),
  ingestColorPage: (imageBase64: string, mediaType: string) =>
    req<{ extracted: ExtractedColorPage }>('/ingest/color-page', {
      method: 'POST',
      admin: true,
      body: { imageBase64, mediaType },
    }),
  colorCommit: (machineId: string, extracted: ExtractedColorPage) =>
    req<{ ok: boolean; summary: ColorCommitSummary }>('/ingest/color-commit', {
      method: 'POST',
      admin: true,
      body: { machineId, extracted },
    }),
  listAssemblies: (machineId: string) =>
    req<Assembly[]>(`/assemblies?machineId=${encodeURIComponent(machineId)}`),
  listVariants: (machineId: string) =>
    req<MachineVariant[]>(`/machines/${encodeURIComponent(machineId)}/variants`),
  getAssemblyFull: (id: string, filter?: { variantId?: string; serial?: string }) => {
    const params = new URLSearchParams();
    if (filter?.variantId) params.set('variantId', filter.variantId);
    if (filter?.serial) params.set('serial', filter.serial);
    const qs = params.toString();
    return req<FullAssembly>(`/assemblies/${id}/full${qs ? `?${qs}` : ''}`);
  },
  uploadAssemblyImage: (id: string, imageBase64: string, mediaType: string, width: number, height: number) =>
    req<{ ok: boolean; imageRef: string }>(`/assemblies/${id}/image`, {
      method: 'POST',
      admin: true,
      body: { imageBase64, mediaType, width, height },
    }),
  saveDots: (id: string, dots: EditorDot[]) =>
    req<{ ok: boolean; count: number }>(`/assemblies/${id}/dots`, {
      method: 'PUT',
      admin: true,
      body: { dots },
    }),
  lookupPart: (number: string) => req<PartFull>(`/parts?number=${encodeURIComponent(number)}`),
  searchParts: (q: string) => req<{ results: SearchResult[] }>(`/parts/search?q=${encodeURIComponent(q)}`),
  getPart: (id: string) => req<PartFull>(`/parts/${encodeURIComponent(id)}`),
  checkAuth: () => req<{ ok: boolean }>('/auth/check', { admin: true }),
  getAiSettings: () => req<AiSettings>('/settings/ai', { admin: true }),
  saveAiSettings: (s: Partial<Pick<AiSettings, 'chatProvider' | 'chatModel' | 'anthropicKey' | 'deepseekKey'>>) =>
    req<AiSettings>('/settings/ai', { method: 'PUT', admin: true, body: s }),
};

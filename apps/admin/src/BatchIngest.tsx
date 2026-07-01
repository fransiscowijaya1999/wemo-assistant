import { useState } from 'react';
import * as pdfjsLib from 'pdfjs-dist';
import workerUrl from 'pdfjs-dist/build/pdf.worker.min.mjs?url';
import { api } from './api';
import { autoMap, b64of } from './ingest-helpers';
import type { ExtractedColorPage, ExtractedPage } from './types';

pdfjsLib.GlobalWorkerOptions.workerSrc = workerUrl;

const RENDER_SCALE = 2;
const CONCURRENCY = 3;

type PageType = 'skip' | 'assembly' | 'color';
type PageStatus = 'pending' | 'extracting' | 'extracted' | 'committing' | 'committed' | 'error';
type PageState = {
  pageNo: number;
  dataUrl: string;
  type: PageType;
  status: PageStatus;
  extracted?: ExtractedPage | ExtractedColorPage;
  info?: string;
  error?: string;
};

function inferGroup(code: string): 'engine' | 'frame' {
  return code.trim().toUpperCase().startsWith('F') ? 'frame' : 'engine';
}

async function renderPdf(
  file: File,
  onProgress: (n: number, total: number) => void,
): Promise<{ pageNo: number; dataUrl: string }[]> {
  const buf = await file.arrayBuffer();
  const pdf = await pdfjsLib.getDocument({ data: buf }).promise;
  const out: { pageNo: number; dataUrl: string }[] = [];
  for (let i = 1; i <= pdf.numPages; i++) {
    const page = await pdf.getPage(i);
    const viewport = page.getViewport({ scale: RENDER_SCALE });
    const canvas = document.createElement('canvas');
    canvas.width = Math.ceil(viewport.width);
    canvas.height = Math.ceil(viewport.height);
    const ctx = canvas.getContext('2d');
    if (!ctx) throw new Error('no 2d canvas context');
    await page.render({ canvas, canvasContext: ctx, viewport }).promise;
    out.push({ pageNo: i, dataUrl: canvas.toDataURL('image/png') });
    onProgress(i, pdf.numPages);
  }
  return out;
}

async function runPool<T>(items: T[], limit: number, worker: (t: T) => Promise<void>): Promise<void> {
  let idx = 0;
  async function next(): Promise<void> {
    while (idx < items.length) {
      const cur = items[idx++];
      await worker(cur);
    }
  }
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, () => next()));
}

export function BatchIngest({ machineId, onCommitted }: { machineId: string; onCommitted: () => void }) {
  const [pages, setPages] = useState<PageState[]>([]);
  const [busy, setBusy] = useState('');
  const [err, setErr] = useState('');
  const [msg, setMsg] = useState('');

  const patch = (i: number, p: Partial<PageState>) =>
    setPages((prev) => prev.map((pg, k) => (k === i ? { ...pg, ...p } : pg)));

  async function onPdf(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setErr('');
    setMsg('');
    setPages([]);
    setBusy('Rendering PDF…');
    try {
      const rendered = await renderPdf(file, (n, t) => setBusy(`Rendering PDF… ${n}/${t}`));
      setPages(rendered.map((r) => ({ pageNo: r.pageNo, dataUrl: r.dataUrl, type: 'skip', status: 'pending' })));
      setMsg(`${rendered.length} pages rendered. Mark each page's type, then Extract selected.`);
    } catch (e2) {
      setErr(String(e2));
    } finally {
      setBusy('');
    }
  }

  const setAll = (type: PageType) => setPages((prev) => prev.map((pg) => ({ ...pg, type })));

  async function extractSelected() {
    const targets = pages
      .map((p, i) => ({ p, i }))
      .filter((x) => x.p.type !== 'skip' && x.p.status !== 'committed');
    if (!targets.length) {
      setErr('Mark some pages as assembly or color first.');
      return;
    }
    if (targets.length > 15 && !window.confirm(`Extract ${targets.length} pages? Each is a paid Claude call.`)) {
      return;
    }
    setErr('');
    setMsg('');
    let done = 0;
    setBusy(`Extracting 0/${targets.length}…`);
    await runPool(targets, CONCURRENCY, async ({ p, i }) => {
      patch(i, { status: 'extracting', error: undefined });
      try {
        const { b64, mediaType } = b64of(p.dataUrl);
        if (p.type === 'assembly') {
          const { extracted } = await api.ingestPage(b64, mediaType);
          patch(i, {
            status: 'extracted',
            extracted,
            info: `${extracted.assembly.code} ${extracted.assembly.name} · ${extracted.items.length} items`,
          });
        } else {
          const { extracted } = await api.ingestColorPage(b64, mediaType);
          patch(i, {
            status: 'extracted',
            extracted,
            info: `${extracted.colors.length} colors · ${extracted.items.length} parts`,
          });
        }
      } catch (e2) {
        patch(i, { status: 'error', error: String(e2) });
      } finally {
        done++;
        setBusy(`Extracting ${done}/${targets.length}…`);
      }
    });
    setBusy('');
    setMsg('Extraction done. Review the pages, then Commit all.');
  }

  async function commitAll() {
    if (!machineId) {
      setErr('Select a machine first.');
      return;
    }
    const targets = pages.map((p, i) => ({ p, i })).filter((x) => x.p.status === 'extracted' && x.p.extracted);
    if (!targets.length) {
      setErr('Nothing extracted to commit.');
      return;
    }
    setErr('');
    setMsg('');
    let done = 0;
    setBusy(`Committing 0/${targets.length}…`);
    // Sequential: dedup/merge relies on earlier writes being visible.
    for (const { p, i } of targets) {
      patch(i, { status: 'committing' });
      try {
        if (p.type === 'assembly') {
          const ex = p.extracted as ExtractedPage;
          const group = inferGroup(ex.assembly.code);
          const { summary } = await api.commitPage(machineId, group, ex);
          let n = 0;
          try {
            n = await autoMap(summary.assemblyId, ex, p.dataUrl);
          } catch {
            /* dots are best-effort */
          }
          patch(i, { status: 'committed', info: `${ex.assembly.code} → ${group}, ${n} dots` });
        } else {
          const ex = p.extracted as ExtractedColorPage;
          const { summary } = await api.colorCommit(machineId, ex);
          patch(i, { status: 'committed', info: `${summary.variantsCreated} color variants` });
        }
      } catch (e2) {
        patch(i, { status: 'error', error: String(e2) });
      } finally {
        done++;
        setBusy(`Committing ${done}/${targets.length}…`);
      }
    }
    setBusy('');
    setMsg('Commit done.');
    onCommitted();
  }

  const nAssembly = pages.filter((p) => p.type === 'assembly').length;
  const nColor = pages.filter((p) => p.type === 'color').length;

  return (
    <section className="card">
      <h2>Whole-catalog batch ingest</h2>
      <div className="row">
        <input type="file" accept="application/pdf" onChange={onPdf} />
        {pages.length > 0 && (
          <>
            <span className="hint">
              {pages.length} pages · {nAssembly} assembly · {nColor} color
            </span>
            <button onClick={() => setAll('assembly')}>All → assembly</button>
            <button onClick={() => setAll('skip')}>All → skip</button>
            <button onClick={extractSelected} disabled={!!busy}>
              Extract selected
            </button>
            <button className="primary" onClick={commitAll} disabled={!!busy || !machineId}>
              Commit all
            </button>
          </>
        )}
      </div>
      <p className="hint">
        Renders the PDF in your browser (pdf.js). Mark front-matter/index pages as “skip”. Each
        assembly/color page is one paid Claude call; group is inferred from the assembly code (E→engine,
        F→frame).
      </p>

      {busy && <p className="busy">{busy}</p>}
      {err && <p className="err">{err}</p>}
      {msg && <p className="ok">{msg}</p>}

      <div className="pagegrid">
        {pages.map((p, i) => (
          <div key={p.pageNo} className={`pagecell ${p.status}`}>
            <img src={p.dataUrl} alt={`page ${p.pageNo}`} />
            <div className="pagemeta">
              <b>p{p.pageNo}</b>
              <select value={p.type} onChange={(e) => patch(i, { type: e.target.value as PageType })}>
                <option value="skip">skip</option>
                <option value="assembly">assembly</option>
                <option value="color">color</option>
              </select>
            </div>
            <div className="pagestatus">
              {p.status}
              {p.info ? `: ${p.info}` : ''}
              {p.error ? `: ${p.error}` : ''}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

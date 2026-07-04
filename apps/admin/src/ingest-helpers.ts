import { api } from './api';
import type { DiagramBox, EditorDot, ExtractedPage } from './types';

export function fileToDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(r.result as string);
    r.onerror = reject;
    r.readAsDataURL(file);
  });
}

export function imageMeta(dataUrl: string): Promise<{ w: number; h: number }> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve({ w: img.naturalWidth, h: img.naturalHeight });
    img.onerror = reject;
    img.src = dataUrl;
  });
}

export function cropToBox(dataUrl: string, box: DiagramBox): Promise<{ dataUrl: string; w: number; h: number }> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => {
      const sx = Math.max(0, box.x * img.naturalWidth);
      const sy = Math.max(0, box.y * img.naturalHeight);
      const sw = Math.min(img.naturalWidth - sx, box.width * img.naturalWidth);
      const sh = Math.min(img.naturalHeight - sy, box.height * img.naturalHeight);
      const canvas = document.createElement('canvas');
      canvas.width = Math.max(1, Math.round(sw));
      canvas.height = Math.max(1, Math.round(sh));
      const ctx = canvas.getContext('2d');
      if (!ctx) return reject(new Error('no 2d canvas context'));
      ctx.drawImage(img, sx, sy, sw, sh, 0, 0, canvas.width, canvas.height);
      resolve({ dataUrl: canvas.toDataURL('image/png'), w: canvas.width, h: canvas.height });
    };
    img.onerror = reject;
    img.src = dataUrl;
  });
}

export function b64of(dataUrl: string): { b64: string; mediaType: string } {
  const [meta, b64] = dataUrl.split(',');
  return { b64, mediaType: meta.substring(5, meta.indexOf(';')) };
}

// After commit: crop the page to the AI's diagram bbox, upload it as the assembly image
// (first diagram page only), then transform this page's per-ref balloon coords into crop
// space and save them. Multi-page assemblies share one diagram, so we MERGE dots: positions
// contributed by other pages are preserved (saveDots replaces the whole assembly's set), and
// only the first page's crop becomes the image so cross-page dots stay on the same picture.
export async function autoMap(assemblyId: string, page: ExtractedPage, pageDataUrl: string): Promise<number> {
  const box = page.diagram ?? null;
  const full = await api.getAssemblyFull(assemblyId);

  // The first diagram page owns the image; later pages of the same assembly keep it.
  if (!full.assembly.imageRef) {
    let uploadUrl = pageDataUrl;
    let w: number;
    let h: number;
    if (box) {
      const cropped = await cropToBox(pageDataUrl, box);
      uploadUrl = cropped.dataUrl;
      w = cropped.w;
      h = cropped.h;
    } else {
      const meta = await imageMeta(pageDataUrl);
      w = meta.w;
      h = meta.h;
    }
    const { b64, mediaType } = b64of(uploadUrl);
    await api.uploadAssemblyImage(assemblyId, b64, mediaType, w, h);
  }

  const idByRef = new Map(full.items.map((it) => [it.refNo, it.id]));
  const thisPageRefs = new Set(page.items.map((it) => it.refNo));
  const dots: EditorDot[] = [];
  // Preserve dots already placed for positions this page doesn't cover (earlier pages of a
  // multi-page assembly) — saveDots overwrites the whole assembly, so resend them.
  for (const it of full.items) {
    if (thisPageRefs.has(it.refNo)) continue;
    for (const d of it.dots) dots.push({ assemblyItemId: it.id, x: d.x, y: d.y });
  }
  let placed = 0;
  for (const it of page.items) {
    const aid = idByRef.get(it.refNo);
    if (!aid || !it.dots) continue;
    for (const d of it.dots) {
      let x = d.x;
      let y = d.y;
      if (box) {
        x = (d.x - box.x) / box.width;
        y = (d.y - box.y) / box.height;
      }
      if (x < 0 || x > 1 || y < 0 || y > 1) continue;
      dots.push({ assemblyItemId: aid, x, y });
      placed++;
    }
  }
  if (dots.length) await api.saveDots(assemblyId, dots);
  return placed;
}

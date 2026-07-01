import { api } from './api';
import type { DiagramBox, ExtractedPage } from './types';

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

// After commit: crop the page to the AI's diagram bbox (if any), upload it as the
// assembly image, then transform the AI's per-ref balloon coords into crop space and save them.
export async function autoMap(assemblyId: string, page: ExtractedPage, pageDataUrl: string): Promise<number> {
  const box = page.diagram ?? null;
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

  const full = await api.getAssemblyFull(assemblyId);
  const idByRef = new Map(full.items.map((it) => [it.refNo, it.id]));
  const dots: { assemblyItemId: string; x: number; y: number }[] = [];
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
    }
  }
  if (dots.length) await api.saveDots(assemblyId, dots);
  return dots.length;
}

import { useEffect, useMemo, useRef, useState, type ChangeEvent, type MouseEvent } from 'react';
import { api, imageUrl } from './api';
import type { Assembly, EditorDot, FullItem } from './types';

function fileToDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(r.result as string);
    r.onerror = reject;
    r.readAsDataURL(file);
  });
}

function imageMeta(dataUrl: string): Promise<{ w: number; h: number }> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve({ w: img.naturalWidth, h: img.naturalHeight });
    img.onerror = reject;
    img.src = dataUrl;
  });
}

export function DotEditor({ machineId }: { machineId: string }) {
  const [assemblies, setAssemblies] = useState<Assembly[]>([]);
  const [asmId, setAsmId] = useState('');
  const [items, setItems] = useState<FullItem[]>([]);
  const [dots, setDots] = useState<EditorDot[]>([]);
  const [selItem, setSelItem] = useState('');
  const [hasImage, setHasImage] = useState(false);
  const [imgV, setImgV] = useState(0);
  const [busy, setBusy] = useState('');
  const [msg, setMsg] = useState('');
  const [err, setErr] = useState('');
  const canvasRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setAsmId('');
    setItems([]);
    setDots([]);
    api.listAssemblies(machineId).then(setAssemblies).catch((e) => setErr(String(e)));
  }, [machineId]);

  async function openAssembly(id: string) {
    setAsmId(id);
    setErr('');
    setMsg('');
    if (!id) return;
    try {
      const full = await api.getAssemblyFull(id);
      setItems(full.items);
      setSelItem(full.items[0]?.id ?? '');
      setDots(full.items.flatMap((it) => it.dots.map((d) => ({ assemblyItemId: it.id, x: d.x, y: d.y }))));
      setHasImage(!!full.assembly.imageRef);
      setImgV((v) => v + 1);
    } catch (e) {
      setErr(String(e));
    }
  }

  const refByItem = useMemo(() => new Map(items.map((it) => [it.id, it.refNo])), [items]);
  const dotsForItem = (id: string) => dots.filter((d) => d.assemblyItemId === id).length;

  function onCanvasClick(e: MouseEvent<HTMLDivElement>) {
    if (!selItem || !canvasRef.current) return;
    const rect = canvasRef.current.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;
    if (x < 0 || x > 1 || y < 0 || y > 1) return;
    setDots((d) => [...d, { assemblyItemId: selItem, x, y }]);
  }
  function removeDot(idx: number, e: MouseEvent) {
    e.stopPropagation();
    setDots((d) => d.filter((_, i) => i !== idx));
  }

  async function onImage(e: ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file || !asmId) return;
    setBusy('Uploading image…');
    setErr('');
    setMsg('');
    try {
      const dataUrl = await fileToDataUrl(file);
      const [meta, b64] = dataUrl.split(',');
      const mediaType = meta.substring(5, meta.indexOf(';'));
      const { w, h } = await imageMeta(dataUrl);
      await api.uploadAssemblyImage(asmId, b64, mediaType, w, h);
      setHasImage(true);
      setImgV((v) => v + 1);
      setMsg('Image uploaded.');
    } catch (e2) {
      setErr(String(e2));
    } finally {
      setBusy('');
    }
  }

  async function save() {
    if (!asmId) return;
    setBusy('Saving dots…');
    setErr('');
    setMsg('');
    try {
      const r = await api.saveDots(asmId, dots);
      setMsg(`Saved ${r.count} dots.`);
    } catch (e) {
      setErr(String(e));
    } finally {
      setBusy('');
    }
  }

  return (
    <section className="card">
      <h2>Dot mapping</h2>
      <label>
        Assembly
        <select value={asmId} onChange={(e) => openAssembly(e.target.value)}>
          <option value="">— select —</option>
          {assemblies.map((a) => (
            <option key={a.id} value={a.id}>
              {a.code} · {a.name}
            </option>
          ))}
        </select>
      </label>

      {asmId && (
        <>
          <div className="row">
            <input type="file" accept="image/*" onChange={onImage} />
            <span className="hint">{hasImage ? 'diagram loaded' : 'no diagram yet — upload one'}</span>
          </div>

          <div className="doteditor">
            <div className="itemlist">
              <p className="hint">Pick a ref, then click the diagram to drop its dot. Click a dot to remove it.</p>
              {items.map((it) => (
                <button
                  key={it.id}
                  className={it.id === selItem ? 'itembtn sel' : 'itembtn'}
                  onClick={() => setSelItem(it.id)}
                >
                  <b>{it.refNo}</b> {it.part?.nameRaw ?? ''} <span className="cnt">{dotsForItem(it.id)}</span>
                </button>
              ))}
            </div>

            <div className="canvaswrap">
              {hasImage ? (
                <div className="canvas" ref={canvasRef} onClick={onCanvasClick}>
                  <img src={`${imageUrl(asmId)}?v=${imgV}`} alt="diagram" draggable={false} />
                  {dots.map((d, i) => (
                    <div
                      key={i}
                      className="marker"
                      style={{ left: `${d.x * 100}%`, top: `${d.y * 100}%` }}
                      title="click to remove"
                      onClick={(e) => removeDot(i, e)}
                    >
                      {refByItem.get(d.assemblyItemId) ?? '?'}
                    </div>
                  ))}
                </div>
              ) : (
                <p className="hint">Upload a diagram image to start placing dots.</p>
              )}
            </div>
          </div>

          <button className="primary" onClick={save} disabled={!!busy}>
            Save dots
          </button>
        </>
      )}

      {busy && <p className="busy">{busy}</p>}
      {err && <p className="err">{err}</p>}
      {msg && <p className="ok">{msg}</p>}
    </section>
  );
}

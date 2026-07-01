import { useEffect, useState, type ChangeEvent } from 'react';
import { api, getToken, setToken } from './api';
import { DotEditor } from './DotEditor';
import type { ExtractedPage, Machine } from './types';

function fileToDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(r.result as string);
    r.onerror = reject;
    r.readAsDataURL(file);
  });
}

export function App() {
  const [token, setTok] = useState(getToken());
  const [machines, setMachines] = useState<Machine[]>([]);
  const [machineId, setMachineId] = useState('');
  const [newBrand, setNewBrand] = useState('Honda');
  const [newModel, setNewModel] = useState('');
  const [groupType, setGroupType] = useState<'engine' | 'frame'>('engine');
  const [imgDataUrl, setImgDataUrl] = useState('');
  const [draft, setDraft] = useState<ExtractedPage | null>(null);
  const [busy, setBusy] = useState('');
  const [msg, setMsg] = useState('');
  const [err, setErr] = useState('');

  useEffect(() => {
    void refreshMachines();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function refreshMachines() {
    try {
      const m = await api.listMachines();
      setMachines(m);
      setMachineId((cur) => cur || m[0]?.id || '');
    } catch (e) {
      setErr(String(e));
    }
  }

  function saveToken() {
    setToken(token);
    setMsg('Token saved.');
  }

  async function createMachine() {
    setErr('');
    setMsg('');
    try {
      const m = await api.createMachine({ brand: newBrand, model: newModel });
      setNewModel('');
      await refreshMachines();
      setMachineId(m.id);
      setMsg(`Created machine ${m.brand} ${m.model}`);
    } catch (e) {
      setErr(String(e));
    }
  }

  async function onFile(e: ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setErr('');
    setMsg('');
    setDraft(null);
    setImgDataUrl(await fileToDataUrl(file));
  }

  async function extract() {
    if (!imgDataUrl) {
      setErr('Choose an image first.');
      return;
    }
    setErr('');
    setMsg('');
    setBusy('Extracting with Claude…');
    try {
      const [meta, b64] = imgDataUrl.split(',');
      const mediaType = meta.substring(5, meta.indexOf(';'));
      const { extracted } = await api.ingestPage(b64, mediaType);
      setDraft(extracted);
      setMsg(`Extracted ${extracted.items.length} items, ${extracted.serviceItems.length} service items. Review below.`);
    } catch (e) {
      setErr(String(e));
    } finally {
      setBusy('');
    }
  }

  async function commit() {
    if (!draft) return;
    if (!machineId) {
      setErr('Select or create a machine first.');
      return;
    }
    setErr('');
    setMsg('');
    setBusy('Committing…');
    try {
      const { summary } = await api.commitPage(machineId, groupType, draft);
      setMsg(`Committed ✓  ${JSON.stringify(summary)}`);
      setDraft(null);
      setImgDataUrl('');
    } catch (e) {
      setErr(String(e));
    } finally {
      setBusy('');
    }
  }

  function updateAssembly(field: 'code' | 'name', v: string) {
    if (!draft) return;
    setDraft({ ...draft, assembly: { ...draft.assembly, [field]: v } });
  }
  function updateItem(i: number, field: 'refNo' | 'description' | 'qty', v: string) {
    if (!draft) return;
    const items = draft.items.slice();
    items[i] = { ...items[i], [field]: field === 'qty' ? (v === '' ? null : Number(v)) : v };
    setDraft({ ...draft, items });
  }
  function updateNumber(i: number, j: number, v: string) {
    if (!draft) return;
    const items = draft.items.slice();
    const pns = items[i].partNumbers.slice();
    pns[j] = { ...pns[j], value: v };
    items[i] = { ...items[i], partNumbers: pns };
    setDraft({ ...draft, items });
  }
  function removeItem(i: number) {
    if (!draft) return;
    setDraft({ ...draft, items: draft.items.filter((_, k) => k !== i) });
  }

  return (
    <div className="app">
      <h1>wemo · admin</h1>

      <section className="card">
        <h2>Connection</h2>
        <label>
          Admin token
          <input value={token} onChange={(e) => setTok(e.target.value)} placeholder="dev-admin-token" />
        </label>
        <button onClick={saveToken}>Save</button>
      </section>

      <section className="card">
        <h2>Machine</h2>
        <label>
          Target
          <select value={machineId} onChange={(e) => setMachineId(e.target.value)}>
            <option value="">— select —</option>
            {machines.map((m) => (
              <option key={m.id} value={m.id}>
                {m.brand} {m.model}
              </option>
            ))}
          </select>
        </label>
        <div className="row">
          <input value={newBrand} onChange={(e) => setNewBrand(e.target.value)} placeholder="brand" />
          <input value={newModel} onChange={(e) => setNewModel(e.target.value)} placeholder="model" />
          <button onClick={createMachine} disabled={!newModel}>
            + New machine
          </button>
        </div>
      </section>

      <section className="card">
        <h2>Ingest a catalog page</h2>
        <div className="row">
          <input type="file" accept="image/*" onChange={onFile} />
          <label>
            Group
            <select value={groupType} onChange={(e) => setGroupType(e.target.value as 'engine' | 'frame')}>
              <option value="engine">engine</option>
              <option value="frame">frame</option>
            </select>
          </label>
          <button onClick={extract} disabled={!imgDataUrl || !!busy}>
            Extract
          </button>
        </div>
        {imgDataUrl && (
          <div className="preview">
            <img src={imgDataUrl} alt="catalog page" />
          </div>
        )}
      </section>

      {busy && <p className="busy">{busy}</p>}
      {err && <p className="err">{err}</p>}
      {msg && <p className="ok">{msg}</p>}

      {draft && (
        <section className="card">
          <h2>Review &amp; edit</h2>
          <div className="row">
            <label>
              Code
              <input value={draft.assembly.code} onChange={(e) => updateAssembly('code', e.target.value)} />
            </label>
            <label>
              Name
              <input value={draft.assembly.name} onChange={(e) => updateAssembly('name', e.target.value)} />
            </label>
          </div>
          <table>
            <thead>
              <tr>
                <th>Ref</th>
                <th>Description</th>
                <th>Qty</th>
                <th>Part numbers</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {draft.items.map((it, i) => (
                <tr key={i}>
                  <td>
                    <input className="w3" value={it.refNo} onChange={(e) => updateItem(i, 'refNo', e.target.value)} />
                  </td>
                  <td>
                    <input
                      className="wide"
                      value={it.description}
                      onChange={(e) => updateItem(i, 'description', e.target.value)}
                    />
                  </td>
                  <td>
                    <input
                      className="w3"
                      value={it.qty ?? ''}
                      onChange={(e) => updateItem(i, 'qty', e.target.value)}
                    />
                  </td>
                  <td>
                    {it.partNumbers.map((pn, j) => (
                      <input
                        key={j}
                        className="num"
                        value={pn.value}
                        onChange={(e) => updateNumber(i, j, e.target.value)}
                      />
                    ))}
                  </td>
                  <td>
                    <button onClick={() => removeItem(i)} title="remove row">
                      ✕
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <p>{draft.serviceItems.length} service (FRT) items will also be saved.</p>
          <button className="primary" onClick={commit} disabled={!!busy || !machineId}>
            Commit to catalog
          </button>
        </section>
      )}

      {machineId && <DotEditor machineId={machineId} />}
    </div>
  );
}

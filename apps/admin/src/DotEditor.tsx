import { useEffect, useMemo, useRef, useState, type MouseEvent } from 'react';
import { Alert, Badge, Box, Button, FileButton, Group, Loader, ScrollArea, Select, Stack, Text } from '@mantine/core';
import { api, imageUrl } from './api';
import { b64of, fileToDataUrl, imageMeta } from './ingest-helpers';
import type { Assembly, EditorDot, FullItem } from './types';

export function DotEditor({ machineId, refreshKey }: { machineId: string; refreshKey: number }) {
  const [assemblies, setAssemblies] = useState<Assembly[]>([]);
  const [asmId, setAsmId] = useState<string | null>(null);
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
    setAsmId(null);
    setItems([]);
    setDots([]);
    api.listAssemblies(machineId).then(setAssemblies).catch((e) => setErr(String(e)));
  }, [machineId, refreshKey]);

  async function openAssembly(id: string | null) {
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

  async function onImage(file: File | null) {
    if (!file || !asmId) return;
    setBusy('Uploading image…');
    setErr('');
    setMsg('');
    try {
      const dataUrl = await fileToDataUrl(file);
      const { b64, mediaType } = b64of(dataUrl);
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
    <Stack>
      <Select
        placeholder="Select assembly"
        data={assemblies.map((a) => ({ value: a.id, label: `${a.code} · ${a.name}` }))}
        value={asmId}
        onChange={openAssembly}
        searchable
        w={360}
      />

      {asmId && (
        <>
          <Group>
            <FileButton onChange={onImage} accept="image/*">
              {(props) => (
                <Button variant="default" {...props}>
                  Upload diagram
                </Button>
              )}
            </FileButton>
            <Text size="sm" c="dimmed">
              {hasImage ? 'diagram loaded' : 'no diagram yet — upload one'}
            </Text>
            <Button onClick={save} loading={busy.startsWith('Saving')} disabled={!hasImage}>
              Save dots
            </Button>
          </Group>

          <Text size="xs" c="dimmed">
            Pick a ref on the left, then click the diagram to drop its dot. Click a dot to remove it.
          </Text>

          <Group align="flex-start" wrap="nowrap">
            <ScrollArea h={520} w={280} type="auto">
              <Stack gap={4}>
                {items.map((it) => (
                  <Button
                    key={it.id}
                    fullWidth
                    size="xs"
                    justify="space-between"
                    variant={it.id === selItem ? 'filled' : 'default'}
                    rightSection={
                      <Badge size="xs" variant="light">
                        {dotsForItem(it.id)}
                      </Badge>
                    }
                    onClick={() => setSelItem(it.id)}
                    styles={{ label: { overflow: 'hidden', textOverflow: 'ellipsis' } }}
                  >
                    {it.refNo} · {it.part?.nameRaw ?? ''}
                  </Button>
                ))}
              </Stack>
            </ScrollArea>

            <Box style={{ flex: 1 }}>
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
                <Text c="dimmed">Upload a diagram image to start placing dots.</Text>
              )}
            </Box>
          </Group>
        </>
      )}

      {busy && (
        <Group gap="xs">
          <Loader size="sm" />
          <Text c="blue">{busy}</Text>
        </Group>
      )}
      {err && <Alert color="red">{err}</Alert>}
      {msg && <Alert color="green">{msg}</Alert>}
    </Stack>
  );
}

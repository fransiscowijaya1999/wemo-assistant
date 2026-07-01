import { useState } from 'react';
import {
  Alert,
  Button,
  FileButton,
  Group,
  Image,
  Loader,
  Select,
  Stack,
  Table,
  Text,
  TextInput,
} from '@mantine/core';
import { api } from './api';
import { autoMap, fileToDataUrl } from './ingest-helpers';
import type { ExtractedPage } from './types';

export function IngestView({ machineId, onCommitted }: { machineId: string; onCommitted: () => void }) {
  const [groupType, setGroupType] = useState<'engine' | 'frame'>('engine');
  const [imgDataUrl, setImgDataUrl] = useState('');
  const [draft, setDraft] = useState<ExtractedPage | null>(null);
  const [busy, setBusy] = useState('');
  const [msg, setMsg] = useState('');
  const [err, setErr] = useState('');

  async function onFile(file: File | null) {
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
      setMsg(`Extracted ${extracted.items.length} items${extracted.diagram ? ' + diagram bbox' : ''}. Review below.`);
    } catch (e) {
      setErr(String(e));
    } finally {
      setBusy('');
    }
  }

  async function commit() {
    if (!draft) return;
    setErr('');
    setMsg('');
    setBusy('Committing…');
    try {
      const { summary } = await api.commitPage(machineId, groupType, draft);
      let extra = '';
      try {
        setBusy('Cropping diagram & placing dots…');
        const n = await autoMap(summary.assemblyId, draft, imgDataUrl);
        extra = draft.diagram ? `; diagram cropped + ${n} dots` : `; ${n} dots`;
      } catch (e2) {
        extra = `; auto-map skipped (${String(e2)})`;
      }
      setMsg(`Committed ✓ ${draft.assembly.code} ${draft.assembly.name}${extra}. Fine-tune in Dot mapping.`);
      setDraft(null);
      setImgDataUrl('');
      onCommitted();
    } catch (e) {
      setErr(String(e));
    } finally {
      setBusy('');
    }
  }

  function setAssembly(field: 'code' | 'name', v: string) {
    if (!draft) return;
    setDraft({ ...draft, assembly: { ...draft.assembly, [field]: v } });
  }
  function setItem(i: number, field: 'refNo' | 'description' | 'qty', v: string) {
    if (!draft) return;
    const items = draft.items.slice();
    items[i] = { ...items[i], [field]: field === 'qty' ? (v === '' ? null : Number(v)) : v };
    setDraft({ ...draft, items });
  }
  function setNumber(i: number, j: number, v: string) {
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
    <Stack>
      <Group align="flex-end">
        <FileButton onChange={onFile} accept="image/*">
          {(props) => (
            <Button variant="default" {...props}>
              Choose page image
            </Button>
          )}
        </FileButton>
        <Select
          label="Group"
          data={['engine', 'frame']}
          value={groupType}
          onChange={(v) => setGroupType((v as 'engine' | 'frame') ?? 'engine')}
          w={130}
          allowDeselect={false}
        />
        <Button onClick={extract} disabled={!imgDataUrl} loading={busy.startsWith('Extract')}>
          Extract
        </Button>
      </Group>

      {imgDataUrl && <Image src={imgDataUrl} alt="page" radius="sm" mah={360} fit="contain" />}

      {busy && (
        <Group gap="xs">
          <Loader size="sm" />
          <Text c="blue">{busy}</Text>
        </Group>
      )}
      {err && <Alert color="red">{err}</Alert>}
      {msg && <Alert color="green">{msg}</Alert>}

      {draft && (
        <Stack>
          <Group>
            <TextInput label="Code" value={draft.assembly.code} onChange={(e) => setAssembly('code', e.currentTarget.value)} />
            <TextInput label="Name" value={draft.assembly.name} onChange={(e) => setAssembly('name', e.currentTarget.value)} />
          </Group>
          <Table withTableBorder withColumnBorders stickyHeader>
            <Table.Thead>
              <Table.Tr>
                <Table.Th w={70}>Ref</Table.Th>
                <Table.Th>Description</Table.Th>
                <Table.Th w={70}>Qty</Table.Th>
                <Table.Th>Part numbers</Table.Th>
                <Table.Th w={50} />
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {draft.items.map((it, i) => (
                <Table.Tr key={i}>
                  <Table.Td>
                    <TextInput size="xs" value={it.refNo} onChange={(e) => setItem(i, 'refNo', e.currentTarget.value)} />
                  </Table.Td>
                  <Table.Td>
                    <TextInput size="xs" value={it.description} onChange={(e) => setItem(i, 'description', e.currentTarget.value)} />
                  </Table.Td>
                  <Table.Td>
                    <TextInput size="xs" value={it.qty ?? ''} onChange={(e) => setItem(i, 'qty', e.currentTarget.value)} />
                  </Table.Td>
                  <Table.Td>
                    <Stack gap={4}>
                      {it.partNumbers.map((pn, j) => (
                        <TextInput key={j} size="xs" ff="monospace" value={pn.value} onChange={(e) => setNumber(i, j, e.currentTarget.value)} />
                      ))}
                    </Stack>
                  </Table.Td>
                  <Table.Td>
                    <Button size="compact-xs" variant="subtle" color="red" onClick={() => removeItem(i)}>
                      ✕
                    </Button>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
          <Text size="sm" c="dimmed">
            {draft.items.reduce((n, it) => n + (it.dots?.length ?? 0), 0)} balloon dots detected ·{' '}
            {draft.serviceItems.length} service (FRT) items will also be saved.
          </Text>
          <Button onClick={commit} loading={busy.startsWith('Commit') || busy.startsWith('Crop')} w={220}>
            Commit to catalog
          </Button>
        </Stack>
      )}
    </Stack>
  );
}

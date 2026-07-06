import { useState } from 'react';
import {
  ActionIcon,
  Alert,
  Button,
  Card,
  FileButton,
  Group,
  Image,
  Paper,
  Select,
  Stack,
  Switch,
  Table,
  Text,
  TextInput,
  ThemeIcon,
  Title,
  Tooltip,
} from '@mantine/core';
import {
  IconAlertCircle,
  IconDatabaseImport,
  IconPhotoUp,
  IconScan,
  IconTrash,
} from '@tabler/icons-react';
import { api } from './api';
import { autoMap, fileToDataUrl, getMapDots, setMapDots } from './ingest-helpers';
import { notifyError, notifySuccess } from './notify';
import type { ExtractedPage } from './types';

type Busy = 'idle' | 'extracting' | 'committing' | 'mapping';

const BUSY_LABEL: Record<Exclude<Busy, 'idle'>, string> = {
  extracting: 'Extracting with Claude…',
  committing: 'Committing…',
  mapping: 'Cropping diagram & placing dots…',
};

export function IngestView({ machineId, onCommitted }: { machineId: string; onCommitted: () => void }) {
  const [groupType, setGroupType] = useState<'engine' | 'frame'>('engine');
  const [imgDataUrl, setImgDataUrl] = useState('');
  const [draft, setDraft] = useState<ExtractedPage | null>(null);
  const [busy, setBusy] = useState<Busy>('idle');
  const [err, setErr] = useState('');
  const [dragOver, setDragOver] = useState(false);
  const [mapDots, setMapDotsState] = useState(getMapDots);

  async function onFile(file: File | null) {
    if (!file) return;
    setErr('');
    setDraft(null);
    setImgDataUrl(await fileToDataUrl(file));
  }

  async function onDrop(e: React.DragEvent) {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files?.[0];
    if (file?.type.startsWith('image/')) await onFile(file);
  }

  async function extract() {
    if (!imgDataUrl) return;
    setErr('');
    setBusy('extracting');
    try {
      const [meta, b64] = imgDataUrl.split(',');
      const mediaType = meta.substring(5, meta.indexOf(';'));
      const { extracted } = await api.ingestPage(b64, mediaType, mapDots);
      setDraft(extracted);
    } catch (e) {
      setErr(String(e));
    } finally {
      setBusy('idle');
    }
  }

  async function commit() {
    if (!draft) return;
    setErr('');
    setBusy('committing');
    try {
      const { summary } = await api.commitPage(machineId, groupType, draft);
      let extra = '';
      try {
        setBusy('mapping');
        const n = await autoMap(summary.assemblyId, draft, imgDataUrl);
        extra = draft.diagram ? `, diagram cropped + ${n} dots` : `, ${n} dots`;
      } catch (e2) {
        extra = `, auto-map skipped (${String(e2)})`;
      }
      const replaced = summary.assembliesReplaced > 0 ? ' (replaced previous version)' : '';
      notifySuccess(
        `Committed ${draft.assembly.code} ${draft.assembly.name}${replaced}`,
        `${summary.itemsCreated} items, ${summary.resolutionsCreated} resolutions${extra}. Fine-tune in Dot mapping.`,
      );
      setDraft(null);
      setImgDataUrl('');
      onCommitted();
    } catch (e) {
      setErr(String(e));
      notifyError('Commit failed', String(e));
    } finally {
      setBusy('idle');
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
  function setNumberSerial(i: number, j: number, field: 'serialFrom' | 'serialTo', v: string) {
    if (!draft) return;
    const items = draft.items.slice();
    const pns = items[i].partNumbers.slice();
    pns[j] = { ...pns[j], [field]: v === '' ? null : v };
    items[i] = { ...items[i], partNumbers: pns };
    setDraft({ ...draft, items });
  }
  // Empty cell removes the entry (= does not apply to that variant); a number upserts it.
  function setVariantQty(i: number, j: number, variant: string, v: string) {
    if (!draft) return;
    const items = draft.items.slice();
    const pns = items[i].partNumbers.slice();
    const vqs = (pns[j].variantQtys ?? []).filter((vq) => vq.variant !== variant);
    if (v !== '') vqs.push({ variant, qty: Number.isNaN(Number(v)) ? null : Number(v) });
    pns[j] = { ...pns[j], variantQtys: vqs };
    items[i] = { ...items[i], partNumbers: pns };
    setDraft({ ...draft, items });
  }
  function removeItem(i: number) {
    if (!draft) return;
    setDraft({ ...draft, items: draft.items.filter((_, k) => k !== i) });
  }

  const variantColumns = draft?.variantColumns ?? [];
  const hasApplicability =
    variantColumns.length > 0 ||
    !!draft?.items.some((it) => it.partNumbers.some((pn) => pn.serialFrom || pn.serialTo || pn.variantQtys?.length));

  return (
    <Stack>
      <Card withBorder>
        <Stack gap="sm">
          <Title order={5}>1 · Page image</Title>
          {!imgDataUrl ? (
            <FileButton onChange={onFile} accept="image/*">
              {(props) => (
                <Paper
                  {...props}
                  component="button"
                  type="button"
                  withBorder
                  p="xl"
                  w="100%"
                  onDragOver={(e: React.DragEvent) => {
                    e.preventDefault();
                    setDragOver(true);
                  }}
                  onDragLeave={() => setDragOver(false)}
                  onDrop={onDrop}
                  style={{
                    borderStyle: 'dashed',
                    borderWidth: 2,
                    cursor: 'pointer',
                    background: dragOver ? 'var(--mantine-primary-color-light)' : 'transparent',
                  }}
                >
                  <Stack align="center" gap={6}>
                    <ThemeIcon variant="light" size="xl" radius="xl">
                      <IconPhotoUp size={26} />
                    </ThemeIcon>
                    <Text fw={500}>Drop a catalog page image here, or click to choose</Text>
                    <Text size="xs" c="dimmed">
                      One exploded-diagram assembly page per image (PNG/JPG)
                    </Text>
                  </Stack>
                </Paper>
              )}
            </FileButton>
          ) : (
            <Stack gap="sm">
              <Image src={imgDataUrl} alt="page" radius="sm" mah={340} fit="contain" />
              <Group>
                <FileButton onChange={onFile} accept="image/*">
                  {(props) => (
                    <Button variant="default" size="xs" leftSection={<IconPhotoUp size={14} />} {...props}>
                      Replace image
                    </Button>
                  )}
                </FileButton>
                <Select
                  size="xs"
                  data={['engine', 'frame']}
                  value={groupType}
                  onChange={(v) => setGroupType((v as 'engine' | 'frame') ?? 'engine')}
                  w={110}
                  allowDeselect={false}
                />
                <Button
                  size="xs"
                  leftSection={<IconScan size={14} />}
                  onClick={extract}
                  loading={busy === 'extracting'}
                  disabled={busy !== 'idle' && busy !== 'extracting'}
                >
                  Extract
                </Button>
                <Tooltip
                  multiline
                  w={240}
                  label="Ask the AI to place balloon dots on the diagram. Off saves tokens — the diagram image is still cropped; place dots by hand in Dot mapping."
                >
                  <Switch
                    size="xs"
                    checked={mapDots}
                    onChange={(e) => {
                      const on = e.currentTarget.checked;
                      setMapDotsState(on);
                      setMapDots(on);
                    }}
                    label="Auto-place dots"
                  />
                </Tooltip>
              </Group>
            </Stack>
          )}
        </Stack>
      </Card>

      {err && (
        <Alert color="red" icon={<IconAlertCircle size={16} />} title="Something went wrong" withCloseButton onClose={() => setErr('')}>
          {err}
        </Alert>
      )}

      {busy === 'extracting' && (
        <Text size="sm" c="dimmed">
          {BUSY_LABEL.extracting} This usually takes 30–60 seconds.
        </Text>
      )}

      {draft && (
        <Card withBorder>
          <Stack gap="sm">
            <Title order={5}>2 · Review & commit</Title>
            <Group>
              <TextInput label="Code" value={draft.assembly.code} onChange={(e) => setAssembly('code', e.currentTarget.value)} />
              <TextInput label="Name" value={draft.assembly.name} onChange={(e) => setAssembly('name', e.currentTarget.value)} />
            </Group>
            {variantColumns.length > 0 && (
              <Text size="sm">Variant columns: {variantColumns.join(', ')}</Text>
            )}
            <Table withTableBorder withColumnBorders stickyHeader striped highlightOnHover>
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
                          <Stack key={j} gap={2}>
                            <TextInput size="xs" ff="monospace" value={pn.value} onChange={(e) => setNumber(i, j, e.currentTarget.value)} />
                            {hasApplicability && (
                              <Group gap={4} pl={8}>
                                <TextInput
                                  size="xs"
                                  w={90}
                                  placeholder="s/n from"
                                  value={pn.serialFrom ?? ''}
                                  onChange={(e) => setNumberSerial(i, j, 'serialFrom', e.currentTarget.value)}
                                />
                                <TextInput
                                  size="xs"
                                  w={90}
                                  placeholder="s/n to"
                                  value={pn.serialTo ?? ''}
                                  onChange={(e) => setNumberSerial(i, j, 'serialTo', e.currentTarget.value)}
                                />
                                {variantColumns.map((vc) => (
                                  <TextInput
                                    key={vc}
                                    size="xs"
                                    w={70}
                                    placeholder={vc}
                                    value={pn.variantQtys?.find((vq) => vq.variant === vc)?.qty ?? ''}
                                    onChange={(e) => setVariantQty(i, j, vc, e.currentTarget.value)}
                                  />
                                ))}
                              </Group>
                            )}
                          </Stack>
                        ))}
                      </Stack>
                    </Table.Td>
                    <Table.Td>
                      <ActionIcon variant="subtle" color="red" aria-label="Remove row" onClick={() => removeItem(i)}>
                        <IconTrash size={16} />
                      </ActionIcon>
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
            <Group justify="space-between" align="center">
              <Text size="sm" c="dimmed">
                {draft.items.reduce((n, it) => n + (it.dots?.length ?? 0), 0)} balloon dots detected ·{' '}
                {draft.serviceItems.length} service (FRT) items will also be saved.
              </Text>
              <Button
                leftSection={<IconDatabaseImport size={16} />}
                onClick={commit}
                loading={busy === 'committing' || busy === 'mapping'}
              >
                {busy === 'mapping' ? BUSY_LABEL.mapping : 'Commit to catalog'}
              </Button>
            </Group>
          </Stack>
        </Card>
      )}
    </Stack>
  );
}

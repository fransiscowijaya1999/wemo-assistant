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
  Stack,
  Table,
  Text,
  TextInput,
  ThemeIcon,
  Title,
} from '@mantine/core';
import {
  IconAlertCircle,
  IconDatabaseImport,
  IconPhotoUp,
  IconScan,
  IconTrash,
} from '@tabler/icons-react';
import { api } from './api';
import { fileToDataUrl } from './ingest-helpers';
import { notifyError, notifySuccess } from './notify';
import type { ExtractedColorPage } from './types';

type Busy = 'idle' | 'extracting' | 'committing';

export function ColorIngestView({ machineId, onCommitted }: { machineId: string; onCommitted: () => void }) {
  const [imgDataUrl, setImgDataUrl] = useState('');
  const [draft, setDraft] = useState<ExtractedColorPage | null>(null);
  const [busy, setBusy] = useState<Busy>('idle');
  const [err, setErr] = useState('');
  const [dragOver, setDragOver] = useState(false);

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
      const { extracted } = await api.ingestColorPage(b64, mediaType);
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
      const { summary } = await api.colorCommit(machineId, draft);
      notifySuccess(
        `Committed ${draft.colors.length} colors · ${draft.items.length} parts`,
        `${summary.colorsCreated} colors + ${summary.variantsCreated} color variants created ` +
          `(${summary.colorsReused} colors reused, ${summary.variantsSkipped} variants skipped).`,
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

  function setColor(i: number, field: 'code' | 'name', v: string) {
    if (!draft) return;
    const colors = draft.colors.slice();
    colors[i] = { ...colors[i], [field]: v };
    setDraft({ ...draft, colors });
  }
  function removeColor(i: number) {
    if (!draft) return;
    setDraft({ ...draft, colors: draft.colors.filter((_, k) => k !== i) });
  }
  function setItem(i: number, field: 'partName' | 'baseNumber' | 'blockCode' | 'refNo', v: string) {
    if (!draft) return;
    const items = draft.items.slice();
    items[i] = { ...items[i], [field]: v === '' && (field === 'blockCode' || field === 'refNo') ? null : v };
    setDraft({ ...draft, items });
  }
  // Empty cell removes the variant (part not offered in that color); a suffix upserts it.
  function setSuffix(i: number, colorCode: string, v: string) {
    if (!draft) return;
    const items = draft.items.slice();
    const variants = items[i].variants.filter((x) => x.colorCode !== colorCode);
    if (v !== '') variants.push({ colorCode, suffix: v });
    items[i] = { ...items[i], variants };
    setDraft({ ...draft, items });
  }
  function removeItem(i: number) {
    if (!draft) return;
    setDraft({ ...draft, items: draft.items.filter((_, k) => k !== i) });
  }

  return (
    <Stack>
      <Card withBorder>
        <Stack gap="sm">
          <Title order={5}>1 · Color-index page image</Title>
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
                    <Text fw={500}>Drop a color-index page image here, or click to choose</Text>
                    <Text size="xs" c="dimmed">
                      A color-suffix table page (base numbers × color columns), PNG/JPG
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
                <Button
                  size="xs"
                  leftSection={<IconScan size={14} />}
                  onClick={extract}
                  loading={busy === 'extracting'}
                  disabled={busy !== 'idle' && busy !== 'extracting'}
                >
                  Extract
                </Button>
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
          Extracting with Claude… This usually takes 30–60 seconds.
        </Text>
      )}

      {draft && (
        <>
          <Card withBorder>
            <Stack gap="sm">
              <Title order={5}>2 · Colors</Title>
              {draft.colors.length === 0 ? (
                <Text size="sm" c="dimmed">
                  No color legend detected on this page.
                </Text>
              ) : (
                <Table withTableBorder withColumnBorders stickyHeader striped highlightOnHover>
                  <Table.Thead>
                    <Table.Tr>
                      <Table.Th w={140}>Code</Table.Th>
                      <Table.Th>Name</Table.Th>
                      <Table.Th w={50} />
                    </Table.Tr>
                  </Table.Thead>
                  <Table.Tbody>
                    {draft.colors.map((col, i) => (
                      <Table.Tr key={i}>
                        <Table.Td>
                          <TextInput size="xs" ff="monospace" value={col.code} onChange={(e) => setColor(i, 'code', e.currentTarget.value)} />
                        </Table.Td>
                        <Table.Td>
                          <TextInput size="xs" value={col.name} onChange={(e) => setColor(i, 'name', e.currentTarget.value)} />
                        </Table.Td>
                        <Table.Td>
                          <ActionIcon variant="subtle" color="red" aria-label="Remove color" onClick={() => removeColor(i)}>
                            <IconTrash size={16} />
                          </ActionIcon>
                        </Table.Td>
                      </Table.Tr>
                    ))}
                  </Table.Tbody>
                </Table>
              )}
            </Stack>
          </Card>

          <Card withBorder>
            <Stack gap="sm">
              <Title order={5}>3 · Colored parts</Title>
              <Text size="xs" c="dimmed">
                Each cell is the suffix appended to the base number for that color (empty = not offered in that color).
              </Text>
              <Table.ScrollContainer minWidth={640}>
                <Table withTableBorder withColumnBorders stickyHeader striped highlightOnHover>
                  <Table.Thead>
                    <Table.Tr>
                      <Table.Th miw={160}>Part</Table.Th>
                      <Table.Th miw={150}>Base number</Table.Th>
                      <Table.Th w={80}>Block</Table.Th>
                      <Table.Th w={70}>Ref</Table.Th>
                      {draft.colors.map((col) => (
                        <Table.Th key={col.code} w={80} title={col.name}>
                          {col.code}
                        </Table.Th>
                      ))}
                      <Table.Th w={50} />
                    </Table.Tr>
                  </Table.Thead>
                  <Table.Tbody>
                    {draft.items.map((it, i) => (
                      <Table.Tr key={i}>
                        <Table.Td>
                          <TextInput size="xs" value={it.partName} onChange={(e) => setItem(i, 'partName', e.currentTarget.value)} />
                        </Table.Td>
                        <Table.Td>
                          <TextInput size="xs" ff="monospace" value={it.baseNumber} onChange={(e) => setItem(i, 'baseNumber', e.currentTarget.value)} />
                        </Table.Td>
                        <Table.Td>
                          <TextInput size="xs" value={it.blockCode ?? ''} onChange={(e) => setItem(i, 'blockCode', e.currentTarget.value)} />
                        </Table.Td>
                        <Table.Td>
                          <TextInput size="xs" value={it.refNo ?? ''} onChange={(e) => setItem(i, 'refNo', e.currentTarget.value)} />
                        </Table.Td>
                        {draft.colors.map((col) => (
                          <Table.Td key={col.code}>
                            <TextInput
                              size="xs"
                              ff="monospace"
                              placeholder="—"
                              value={it.variants.find((x) => x.colorCode === col.code)?.suffix ?? ''}
                              onChange={(e) => setSuffix(i, col.code, e.currentTarget.value)}
                            />
                          </Table.Td>
                        ))}
                        <Table.Td>
                          <ActionIcon variant="subtle" color="red" aria-label="Remove row" onClick={() => removeItem(i)}>
                            <IconTrash size={16} />
                          </ActionIcon>
                        </Table.Td>
                      </Table.Tr>
                    ))}
                  </Table.Tbody>
                </Table>
              </Table.ScrollContainer>
              <Group justify="space-between" align="center">
                <Text size="sm" c="dimmed">
                  {draft.items.reduce((n, it) => n + it.variants.length, 0)} color variants across {draft.items.length} parts.
                </Text>
                <Button leftSection={<IconDatabaseImport size={16} />} onClick={commit} loading={busy === 'committing'}>
                  Commit to catalog
                </Button>
              </Group>
            </Stack>
          </Card>
        </>
      )}
    </Stack>
  );
}

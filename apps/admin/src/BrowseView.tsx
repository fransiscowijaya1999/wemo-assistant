import { useEffect, useState } from 'react';
import {
  Badge,
  Button,
  Card,
  Group,
  Paper,
  Select,
  SimpleGrid,
  Skeleton,
  Stack,
  Table,
  Text,
  TextInput,
  ThemeIcon,
  Title,
} from '@mantine/core';
import { IconBarcode, IconPhotoScan, IconPlus, IconSearch, IconStack2 } from '@tabler/icons-react';
import { api, imageUrl } from './api';
import { notifySuccess } from './notify';
import type { Assembly, FullAssembly, MachineVariant, PartFull, Resolution, SearchResult } from './types';

function serialText(from: string | null, to: string | null): string {
  if (from && to) return ` · s/n ${from}–${to}`;
  if (from) return ` · s/n ≥${from}`;
  if (to) return ` · s/n ≤${to}`;
  return '';
}

function ApplicabilityBadge({
  number,
  variantName,
  qty,
  serialFrom,
  serialTo,
}: {
  number: string | null;
  variantName: string | null;
  qty: number;
  serialFrom: string | null;
  serialTo: string | null;
}) {
  return (
    <Badge variant="light" color={variantName ? 'teal' : 'gray'}>
      {number ?? '?'}
      {variantName ? ` · ${variantName}` : ''} ×{qty}
      {serialText(serialFrom, serialTo)}
    </Badge>
  );
}

function StatTile({ label, value }: { label: string; value: number }) {
  return (
    <Paper withBorder p="sm">
      <Text size="xs" c="dimmed">
        {label}
      </Text>
      <Text fw={600} fz="xl">
        {value}
      </Text>
    </Paper>
  );
}

export function BrowseView({
  machineId,
  refreshKey,
  onMachineCreated,
  onGoToIngest,
}: {
  machineId: string;
  refreshKey: number;
  onMachineCreated: () => void;
  onGoToIngest?: () => void;
}) {
  const [brand, setBrand] = useState('Honda');
  const [model, setModel] = useState('');
  const [machineErr, setMachineErr] = useState('');
  const [assemblies, setAssemblies] = useState<Assembly[]>([]);
  const [variants, setVariants] = useState<MachineVariant[]>([]);
  const [variantId, setVariantId] = useState<string | null>(null);
  const [serial, setSerial] = useState('');
  const [asmId, setAsmId] = useState<string | null>(null);
  const [full, setFull] = useState<FullAssembly | null>(null);
  const [loadingFull, setLoadingFull] = useState(false);
  const [browseErr, setBrowseErr] = useState('');
  const [lookupNo, setLookupNo] = useState('');
  const [candidates, setCandidates] = useState<SearchResult[]>([]);
  const [part, setPart] = useState<PartFull | null>(null);
  const [lookupState, setLookupState] = useState<'idle' | 'loading' | 'notfound' | 'error'>('idle');
  const [lookupErr, setLookupErr] = useState('');

  useEffect(() => {
    setAsmId(null);
    setFull(null);
    setVariantId(null);
    setSerial('');
    setBrowseErr('');
    if (!machineId) {
      setAssemblies([]);
      setVariants([]);
      return;
    }
    api.listAssemblies(machineId).then(setAssemblies).catch((e) => setBrowseErr(String(e)));
    api.listVariants(machineId).then(setVariants).catch((e) => setBrowseErr(String(e)));
  }, [machineId, refreshKey]);

  async function createMachine() {
    setMachineErr('');
    try {
      await api.createMachine({ brand, model });
      notifySuccess(`Created ${brand} ${model}`);
      setModel('');
      onMachineCreated();
    } catch (e) {
      setMachineErr(String(e));
    }
  }

  async function openAssembly(id: string | null, filter?: { variantId?: string; serial?: string }) {
    setAsmId(id);
    setFull(null);
    setBrowseErr('');
    if (!id) return;
    setLoadingFull(true);
    try {
      setFull(await api.getAssemblyFull(id, filter));
    } catch (e) {
      setBrowseErr(String(e));
    } finally {
      setLoadingFull(false);
    }
  }

  function applyFilter(nextVariantId: string | null, nextSerial: string) {
    setVariantId(nextVariantId);
    setSerial(nextSerial);
    if (asmId) {
      void openAssembly(asmId, {
        variantId: nextVariantId ?? undefined,
        serial: nextSerial.trim() || undefined,
      });
    }
  }

  async function lookup() {
    if (!lookupNo.trim()) return;
    setPart(null);
    setCandidates([]);
    setLookupErr('');
    setLookupState('loading');
    try {
      const { results } = await api.searchParts(lookupNo.trim());
      if (results.length === 0) {
        setLookupState('notfound');
        return;
      }
      setCandidates(results);
      setLookupState('idle');
      if (results.length === 1) await openPart(results[0].partId);
    } catch (e) {
      setLookupErr(String(e));
      setLookupState('error');
    }
  }

  async function openPart(id: string) {
    try {
      setPart(await api.getPart(id));
    } catch (e) {
      setLookupErr(String(e));
      setLookupState('error');
    }
  }

  const nEngine = assemblies.filter((a) => a.groupType === 'engine').length;
  const nFrame = assemblies.filter((a) => a.groupType === 'frame').length;

  return (
    <Stack>
      <Card withBorder>
        <Stack gap="sm">
          <Group gap="xs">
            <ThemeIcon variant="light" size="sm">
              <IconPlus size={14} />
            </ThemeIcon>
            <Title order={5}>New machine</Title>
          </Group>
          <Group align="flex-end">
            <TextInput label="Brand" value={brand} onChange={(e) => setBrand(e.currentTarget.value)} />
            <TextInput label="Model" value={model} onChange={(e) => setModel(e.currentTarget.value)} />
            <Button leftSection={<IconPlus size={16} />} onClick={createMachine} disabled={!model}>
              Create
            </Button>
          </Group>
          {machineErr && (
            <Text size="sm" c="red">
              {machineErr}
            </Text>
          )}
        </Stack>
      </Card>

      <Card withBorder>
        <Stack gap="sm">
          <Group gap="xs">
            <ThemeIcon variant="light" size="sm">
              <IconStack2 size={14} />
            </ThemeIcon>
            <Title order={5}>Browse assemblies</Title>
          </Group>

          {!machineId ? (
            <Text c="dimmed" size="sm">
              Select a machine (top-right) or create one above.
            </Text>
          ) : assemblies.length === 0 ? (
            <Stack align="center" gap={6} py="md">
              <ThemeIcon variant="light" size="xl" radius="xl">
                <IconPhotoScan size={26} />
              </ThemeIcon>
              <Text fw={500}>No assemblies yet</Text>
              <Text size="xs" c="dimmed">
                Ingest a catalog page to start building this machine's catalog.
              </Text>
              {onGoToIngest && (
                <Button size="xs" variant="light" onClick={onGoToIngest}>
                  Go to Ingest
                </Button>
              )}
            </Stack>
          ) : (
            <>
              <SimpleGrid cols={{ base: 2, sm: 4 }} spacing="xs">
                <StatTile label="Assemblies" value={assemblies.length} />
                <StatTile label="Engine group" value={nEngine} />
                <StatTile label="Frame group" value={nFrame} />
                <StatTile label="Variants" value={variants.length} />
              </SimpleGrid>

              <Group align="flex-end">
                <Select
                  placeholder="Select assembly"
                  data={assemblies.map((a) => ({ value: a.id, label: `${a.code} · ${a.name} (${a.groupType})` }))}
                  value={asmId}
                  onChange={(id) =>
                    openAssembly(id, { variantId: variantId ?? undefined, serial: serial.trim() || undefined })
                  }
                  searchable
                  w={360}
                />
                {variants.length > 0 && (
                  <>
                    <Select
                      label="Variant"
                      placeholder="All variants"
                      data={variants.map((v) => ({ value: v.id, label: v.name }))}
                      value={variantId}
                      onChange={(v) => applyFilter(v, serial)}
                      clearable
                      w={160}
                    />
                    <TextInput
                      label="Frame serial"
                      placeholder="e.g. 1008001"
                      value={serial}
                      onChange={(e) => setSerial(e.currentTarget.value)}
                      onBlur={(e) => applyFilter(variantId, e.currentTarget.value)}
                      w={140}
                    />
                  </>
                )}
              </Group>

              {browseErr && (
                <Text size="sm" c="red">
                  {browseErr}
                </Text>
              )}

              {loadingFull && (
                <Stack gap={6}>
                  <Skeleton height={28} />
                  <Skeleton height={28} />
                  <Skeleton height={28} />
                  <Skeleton height={28} />
                </Stack>
              )}

              {full && !loadingFull && full.assembly.imageRef && (
                <div className="canvas" style={{ cursor: 'default', maxWidth: 640, pointerEvents: 'none' }}>
                  <img src={imageUrl(full.assembly.id)} alt={`${full.assembly.code} diagram`} draggable={false} />
                  {full.items.flatMap((it) =>
                    it.dots.map((d, k) => (
                      <div
                        key={`${it.id}-${k}`}
                        className="marker"
                        style={{ left: `${d.x * 100}%`, top: `${d.y * 100}%`, cursor: 'default' }}
                      >
                        {it.refNo}
                      </div>
                    )),
                  )}
                </div>
              )}

              {full && !loadingFull && (
                <Table withTableBorder striped highlightOnHover>
                  <Table.Thead>
                    <Table.Tr>
                      <Table.Th w={60}>Ref</Table.Th>
                      <Table.Th>Part</Table.Th>
                      <Table.Th>Applies to</Table.Th>
                      <Table.Th w={80}>Dots</Table.Th>
                    </Table.Tr>
                  </Table.Thead>
                  <Table.Tbody>
                    {full.items.map((it) => (
                      <Table.Tr key={it.id}>
                        <Table.Td>{it.refNo}</Table.Td>
                        <Table.Td>{it.part?.nameRaw ?? '—'}</Table.Td>
                        <Table.Td>
                          {it.resolutions.length === 0 ? (
                            <Text c="dimmed" size="sm">
                              —
                            </Text>
                          ) : (
                            <Group gap={4}>
                              {it.resolutions.map((r: Resolution) => (
                                <ApplicabilityBadge
                                  key={r.id}
                                  number={r.partNumberValue}
                                  variantName={r.variantName}
                                  qty={r.qty}
                                  serialFrom={r.serialFrom}
                                  serialTo={r.serialTo}
                                />
                              ))}
                            </Group>
                          )}
                        </Table.Td>
                        <Table.Td>{it.dots.length}</Table.Td>
                      </Table.Tr>
                    ))}
                  </Table.Tbody>
                </Table>
              )}
            </>
          )}
        </Stack>
      </Card>

      <Card withBorder>
        <Stack gap="sm">
          <Group gap="xs">
            <ThemeIcon variant="light" size="sm">
              <IconBarcode size={14} />
            </ThemeIcon>
            <Title order={5}>Search parts</Title>
          </Group>
          <Group align="flex-end">
            <TextInput
              label="Part number (full or partial), name, or alias"
              placeholder="e.g. 31928MFF, 31928-MFF-D01, or “gasket”"
              value={lookupNo}
              onChange={(e) => setLookupNo(e.currentTarget.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') void lookup();
              }}
              w={320}
            />
            <Button
              leftSection={<IconSearch size={16} />}
              onClick={lookup}
              disabled={!lookupNo.trim()}
              loading={lookupState === 'loading'}
            >
              Search
            </Button>
          </Group>

          {lookupState === 'notfound' && (
            <Text size="sm" c="dimmed">
              No matches. Try fewer characters of the number (dashes optional), or a name/alias.
            </Text>
          )}

          {candidates.length > 1 && (
            <Stack gap={4}>
              <Text size="xs" c="dimmed" fw={500}>
                {candidates.length} matches — pick one
              </Text>
              <Group gap={6}>
                {candidates.map((r) => (
                  <Button
                    key={r.partId}
                    size="compact-xs"
                    variant={part?.id === r.partId ? 'filled' : 'light'}
                    onClick={() => openPart(r.partId)}
                  >
                    {r.primaryNumber ? `${r.primaryNumber} · ` : ''}
                    {r.name}
                  </Button>
                ))}
              </Group>
            </Stack>
          )}
          {lookupState === 'error' && (
            <Text size="sm" c="red">
              {lookupErr}
            </Text>
          )}

          {part && (
            <Paper withBorder p="md">
              <Stack gap="xs">
                <Text fw={600}>{part.nameRaw}</Text>
                <Group gap="xs">
                  {part.numbers.map((n) => (
                    <Badge key={n.value} variant={n.isPrimary ? 'filled' : 'light'} color={n.kind === 'oem' ? 'wemo' : 'gray'}>
                      {n.value} · {n.kind}
                      {n.brand ? ` · ${n.brand}` : ''}
                    </Badge>
                  ))}
                </Group>
                {part.colorVariants.length > 0 && (
                  <Group gap="xs">
                    {part.colorVariants.map((cv) => (
                      <Badge key={cv.id} color="grape" variant="light">
                        {cv.suffixCode} → {cv.fullNumber}
                      </Badge>
                    ))}
                  </Group>
                )}
                {part.placements.length > 0 && (
                  <Stack gap={4}>
                    <Text size="xs" c="dimmed" fw={500}>
                      Appears in
                    </Text>
                    {part.placements.map((pl) => (
                      <Group key={pl.assemblyItemId} gap="xs">
                        <Text size="sm">
                          {pl.assemblyCode} {pl.assemblyName} · ref {pl.refNo} · {pl.machine}
                        </Text>
                        {pl.applicability.map((a, k) => (
                          <ApplicabilityBadge
                            key={k}
                            number={a.number}
                            variantName={a.variantName}
                            qty={a.qty}
                            serialFrom={a.serialFrom}
                            serialTo={a.serialTo}
                          />
                        ))}
                      </Group>
                    ))}
                  </Stack>
                )}
              </Stack>
            </Paper>
          )}
        </Stack>
      </Card>
    </Stack>
  );
}

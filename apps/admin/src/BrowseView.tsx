import { useEffect, useState } from 'react';
import { Alert, Badge, Button, Divider, Group, Select, Stack, Table, Text, TextInput, Title } from '@mantine/core';
import { api } from './api';
import type { Assembly, FullAssembly, MachineVariant, PartFull, Resolution } from './types';

function serialText(from: string | null, to: string | null): string {
  if (from && to) return ` · s/n ${from}–${to}`;
  if (from) return ` · s/n ≥${from}`;
  if (to) return ` · s/n ≤${to}`;
  return '';
}

export function BrowseView({
  machineId,
  refreshKey,
  onMachineCreated,
}: {
  machineId: string;
  refreshKey: number;
  onMachineCreated: () => void;
}) {
  const [brand, setBrand] = useState('Honda');
  const [model, setModel] = useState('');
  const [assemblies, setAssemblies] = useState<Assembly[]>([]);
  const [variants, setVariants] = useState<MachineVariant[]>([]);
  const [variantId, setVariantId] = useState<string | null>(null);
  const [serial, setSerial] = useState('');
  const [asmId, setAsmId] = useState<string | null>(null);
  const [full, setFull] = useState<FullAssembly | null>(null);
  const [lookupNo, setLookupNo] = useState('');
  const [part, setPart] = useState<PartFull | null>(null);
  const [err, setErr] = useState('');
  const [msg, setMsg] = useState('');

  useEffect(() => {
    setAsmId(null);
    setFull(null);
    setVariantId(null);
    setSerial('');
    if (!machineId) {
      setAssemblies([]);
      setVariants([]);
      return;
    }
    api.listAssemblies(machineId).then(setAssemblies).catch((e) => setErr(String(e)));
    api.listVariants(machineId).then(setVariants).catch((e) => setErr(String(e)));
  }, [machineId, refreshKey]);

  async function createMachine() {
    setErr('');
    setMsg('');
    try {
      await api.createMachine({ brand, model });
      setModel('');
      setMsg(`Created ${brand} ${model}`);
      onMachineCreated();
    } catch (e) {
      setErr(String(e));
    }
  }

  async function openAssembly(id: string | null, filter?: { variantId?: string; serial?: string }) {
    setAsmId(id);
    setFull(null);
    if (!id) return;
    try {
      setFull(await api.getAssemblyFull(id, filter));
    } catch (e) {
      setErr(String(e));
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
    setErr('');
    setPart(null);
    if (!lookupNo.trim()) return;
    try {
      setPart(await api.lookupPart(lookupNo.trim()));
    } catch (e) {
      setErr(String(e));
    }
  }

  return (
    <Stack>
      <Title order={4}>New machine</Title>
      <Group align="flex-end">
        <TextInput label="Brand" value={brand} onChange={(e) => setBrand(e.currentTarget.value)} />
        <TextInput label="Model" value={model} onChange={(e) => setModel(e.currentTarget.value)} />
        <Button onClick={createMachine} disabled={!model}>
          Create
        </Button>
      </Group>

      {err && <Alert color="red">{err}</Alert>}
      {msg && <Alert color="green">{msg}</Alert>}

      <Divider my="sm" />
      <Title order={4}>Browse assemblies</Title>
      {!machineId ? (
        <Text c="dimmed">Select a machine above.</Text>
      ) : (
        <>
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
                  w={140}
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
          {full && (
            <Table withTableBorder>
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
                            <Badge key={r.id} variant="light" color={r.variantName ? 'teal' : 'gray'}>
                              {r.partNumberValue ?? '?'}
                              {r.variantName ? ` · ${r.variantName}` : ''} ×{r.qty}
                              {serialText(r.serialFrom, r.serialTo)}
                            </Badge>
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

      <Divider my="sm" />
      <Title order={4}>Lookup part by any number</Title>
      <Group align="flex-end">
        <TextInput
          label="Part number"
          placeholder="e.g. 31928-MFF-D01"
          value={lookupNo}
          onChange={(e) => setLookupNo(e.currentTarget.value)}
          w={280}
        />
        <Button onClick={lookup} disabled={!lookupNo.trim()}>
          Look up
        </Button>
      </Group>
      {part && (
        <Stack gap="xs">
          <Text fw={600}>{part.nameRaw}</Text>
          <Group gap="xs">
            {part.numbers.map((n) => (
              <Badge key={n.value} variant={n.isPrimary ? 'filled' : 'light'} color={n.kind === 'oem' ? 'blue' : 'gray'}>
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
              {part.placements.map((pl) => (
                <Group key={pl.assemblyItemId} gap="xs">
                  <Text size="sm">
                    {pl.assemblyCode} {pl.assemblyName} · ref {pl.refNo} · {pl.machine}
                  </Text>
                  {pl.applicability.map((a, k) => (
                    <Badge key={k} variant="light" color={a.variantName ? 'teal' : 'gray'}>
                      {a.number ?? '?'}
                      {a.variantName ? ` · ${a.variantName}` : ''} ×{a.qty}
                      {serialText(a.serialFrom, a.serialTo)}
                    </Badge>
                  ))}
                </Group>
              ))}
            </Stack>
          )}
        </Stack>
      )}
    </Stack>
  );
}

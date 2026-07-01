import { useEffect, useState } from 'react';
import { Alert, Badge, Button, Divider, Group, Select, Stack, Table, Text, TextInput, Title } from '@mantine/core';
import { api } from './api';
import type { Assembly, FullAssembly, PartFull } from './types';

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
  const [asmId, setAsmId] = useState<string | null>(null);
  const [full, setFull] = useState<FullAssembly | null>(null);
  const [lookupNo, setLookupNo] = useState('');
  const [part, setPart] = useState<PartFull | null>(null);
  const [err, setErr] = useState('');
  const [msg, setMsg] = useState('');

  useEffect(() => {
    setAsmId(null);
    setFull(null);
    if (!machineId) {
      setAssemblies([]);
      return;
    }
    api.listAssemblies(machineId).then(setAssemblies).catch((e) => setErr(String(e)));
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

  async function openAssembly(id: string | null) {
    setAsmId(id);
    setFull(null);
    if (!id) return;
    try {
      setFull(await api.getAssemblyFull(id));
    } catch (e) {
      setErr(String(e));
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
          <Select
            placeholder="Select assembly"
            data={assemblies.map((a) => ({ value: a.id, label: `${a.code} · ${a.name} (${a.groupType})` }))}
            value={asmId}
            onChange={openAssembly}
            searchable
            w={360}
          />
          {full && (
            <Table withTableBorder>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th w={60}>Ref</Table.Th>
                  <Table.Th>Part</Table.Th>
                  <Table.Th w={80}>Dots</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {full.items.map((it) => (
                  <Table.Tr key={it.id}>
                    <Table.Td>{it.refNo}</Table.Td>
                    <Table.Td>{it.part?.nameRaw ?? '—'}</Table.Td>
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
        </Stack>
      )}
    </Stack>
  );
}

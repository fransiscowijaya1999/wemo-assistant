import { useCallback, useEffect, useState } from 'react';
import { Container, Group, MantineProvider, Select, Tabs, Text, Title } from '@mantine/core';
import { api } from './api';
import type { Machine } from './types';
import { IngestView } from './IngestView';
import { BatchIngest } from './BatchIngest';
import { DotEditor } from './DotEditor';
import { BrowseView } from './BrowseView';
import { SettingsView } from './SettingsView';

function NeedMachine() {
  return <Text c="dimmed">Select a machine (top-right), or create one in the Browse tab, to continue.</Text>;
}

export function App() {
  const [machines, setMachines] = useState<Machine[]>([]);
  const [machineId, setMachineId] = useState('');
  const [tab, setTab] = useState<string | null>('ingest');
  const [refreshKey, setRefreshKey] = useState(0);

  const refreshMachines = useCallback(async () => {
    try {
      const m = await api.listMachines();
      setMachines(m);
      setMachineId((cur) => cur || m[0]?.id || '');
    } catch {
      /* surfaced in views */
    }
  }, []);

  useEffect(() => {
    void refreshMachines();
  }, [refreshMachines]);

  const bump = () => setRefreshKey((v) => v + 1);

  return (
    <MantineProvider>
      <Container size="lg" py="md">
        <Group justify="space-between" align="center" mb="md">
          <Title order={2}>wemo · admin</Title>
          <Select
            placeholder="Select machine"
            data={machines.map((m) => ({ value: m.id, label: `${m.brand} ${m.model}` }))}
            value={machineId || null}
            onChange={(v) => setMachineId(v ?? '')}
            searchable
            w={300}
            nothingFoundMessage="No machines — create one in Browse"
          />
        </Group>

        <Tabs value={tab} onChange={setTab} keepMounted={false}>
          <Tabs.List>
            <Tabs.Tab value="ingest">Ingest page</Tabs.Tab>
            <Tabs.Tab value="batch">Batch (PDF)</Tabs.Tab>
            <Tabs.Tab value="dots">Dot mapping</Tabs.Tab>
            <Tabs.Tab value="browse">Browse</Tabs.Tab>
            <Tabs.Tab value="settings">Settings</Tabs.Tab>
          </Tabs.List>

          <Tabs.Panel value="ingest" pt="md">
            {machineId ? <IngestView machineId={machineId} onCommitted={bump} /> : <NeedMachine />}
          </Tabs.Panel>
          <Tabs.Panel value="batch" pt="md">
            {machineId ? <BatchIngest machineId={machineId} onCommitted={bump} /> : <NeedMachine />}
          </Tabs.Panel>
          <Tabs.Panel value="dots" pt="md">
            {machineId ? <DotEditor machineId={machineId} refreshKey={refreshKey} /> : <NeedMachine />}
          </Tabs.Panel>
          <Tabs.Panel value="browse" pt="md">
            <BrowseView machineId={machineId} refreshKey={refreshKey} onMachineCreated={refreshMachines} />
          </Tabs.Panel>
          <Tabs.Panel value="settings" pt="md">
            <SettingsView />
          </Tabs.Panel>
        </Tabs>
      </Container>
    </MantineProvider>
  );
}

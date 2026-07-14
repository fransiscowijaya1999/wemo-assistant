import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActionIcon,
  Badge,
  Button,
  Divider,
  Group,
  Modal,
  NumberInput,
  Paper,
  ScrollArea,
  Stack,
  Select,
  Table,
  Tabs,
  Text,
  TextInput,
  Title,
} from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { IconBike, IconEdit, IconPlus, IconTrash, IconUser, IconX } from '@tabler/icons-react';
import { api } from './api';
import type { Customer, CustomerVehicle, Machine, MaintenanceRecord, RecordWithItems, VehicleListRow } from './types';
import { notifyError, notifySuccess } from './notify';

type TabType = 'customers' | 'vehicles' | 'records';

export function CustomersView() {
  const [tab, setTab] = useState<TabType>('customers');
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [search, setSearch] = useState('');
  const [selectedCustomer, setSelectedCustomer] = useState<Customer & { vehicles?: CustomerVehicle[]; records?: RecordWithItems[] } | null>(null);
  const [selectedVehicle, setSelectedVehicle] = useState<CustomerVehicle | null>(null);
  const [selectedRecord, setSelectedRecord] = useState<RecordWithItems | null>(null);
  const [machines, setMachines] = useState<Machine[]>([]);

  // --- Vehicles tab state ---
  const [allVehicles, setAllVehicles] = useState<VehicleListRow[]>([]);
  const [vehicleSearch, setVehicleSearch] = useState('');

  // --- Records tab state ---
  const [allRecords, setAllRecords] = useState<(MaintenanceRecord & { customerName: string })[]>([]);
  const [recordSearch, setRecordSearch] = useState('');
  const [recordTypeFilter, setRecordTypeFilter] = useState<string | null>(null);

  // Modal states
  const [editModalOpened, { open: openEdit, close: closeEdit }] = useDisclosure(false);
  const [editType, setEditType] = useState<'customer' | 'vehicle' | 'record'>('customer');
  const [vehicleModalOpened, { open: openVehicle, close: closeVehicle }] = useDisclosure(false);
  const [recordModalOpened, { open: openRecord, close: closeRecord }] = useDisclosure(false);

  // Form states
  const [editData, setEditData] = useState<Partial<Customer>>({});
  const [vehicleData, setVehicleData] = useState<Partial<CustomerVehicle>>({});
  const [recordData, setRecordData] = useState<Partial<Omit<MaintenanceRecord, 'id' | 'createdAt' | 'updatedAt' | 'deletedAt'>>>({});
  const [recordVehicles, setRecordVehicles] = useState<CustomerVehicle[]>([]);

  useEffect(() => {
    if (recordModalOpened && recordData.customerId) {
      if (selectedCustomer?.id === recordData.customerId && selectedCustomer.vehicles) {
        setRecordVehicles(selectedCustomer.vehicles);
      } else {
        api.getCustomerVehicles(recordData.customerId)
          .then(setRecordVehicles)
          .catch((e) => console.error('Failed to load vehicles for record', e));
      }
    } else {
      setRecordVehicles([]);
    }
  }, [recordModalOpened, recordData.customerId, selectedCustomer]);

  const refreshCustomers = useCallback(async () => {
    try {
      const data = await api.listCustomers();
      setCustomers(data);
    } catch (e) {
      notifyError('Failed to load customers', String(e));
    }
  }, []);

  // Load machines for vehicle form autocomplete
  const refreshMachines = useCallback(async () => {
    try {
      const m = await api.listMachines();
      setMachines(m);
    } catch (e) {
      notifyError('Could not load machines', String(e));
    }
  }, []);

  // Load all vehicles for the Vehicles tab
  const refreshVehicles = useCallback(async () => {
    try {
      const v = await api.listVehicles(vehicleSearch || undefined);
      setAllVehicles(v);
    } catch (e) {
      notifyError('Failed to load vehicles', String(e));
    }
  }, [vehicleSearch]);

  // Load all records for the Records tab (with customer name)
  const refreshRecords = useCallback(async () => {
    try {
      const [recs, custs] = await Promise.all([
        api.listRecords({ type: recordTypeFilter ?? undefined }),
        api.listCustomers(),
      ]);
      const custMap = new Map(custs.map((c) => [c.id, c.name]));
      const enriched = recs.map((r) => ({ ...r, customerName: custMap.get(r.customerId) ?? r.customerId }));
      setAllRecords(enriched);
    } catch (e) {
      notifyError('Failed to load records', String(e));
    }
  }, [recordTypeFilter]);

  useEffect(() => {
    void refreshCustomers();
    void refreshMachines();
  }, [refreshCustomers, refreshMachines]);

  // Refresh vehicles/records when tab changes
  useEffect(() => {
    if (tab === 'vehicles') void refreshVehicles();
    if (tab === 'records') void refreshRecords();
  }, [tab, refreshVehicles, refreshRecords]);

  // Filter customers by search
  const filteredCustomers = useMemo(() => {
    if (!search.trim()) return customers;
    const terms = search.toLowerCase().split(/\s+/).filter(Boolean);
    return customers.filter((c) => {
      const hay = `${c.name} ${c.phone ?? ''} ${c.email ?? ''} ${c.tag ?? ''}`.toLowerCase();
      return terms.every((term) => hay.includes(term));
    });
  }, [customers, search]);

  // Filter records by search (client-side)
  const filteredRecords = useMemo(() => {
    if (!recordSearch.trim()) return allRecords;
    const terms = recordSearch.toLowerCase().split(/\s+/).filter(Boolean);
    return allRecords.filter((r) => {
      const hay = `${r.customerName} ${r.description} ${r.invoiceNumber ?? ''} ${r.type}`.toLowerCase();
      return terms.every((term) => hay.includes(term));
    });
  }, [allRecords, recordSearch]);

  // Load customer details
  const loadCustomerDetails = useCallback(async (customer: Customer) => {
    try {
      const [vehicles, records] = await Promise.all([
        api.getCustomerVehicles(customer.id),
        api.getCustomerRecords(customer.id),
      ]);
      // Enrich records with items
      const enrichedRecords = await Promise.all(
        records.map(async (r) => {
          const items = await api.getRecordItems(r.id);
          return { ...r, items } as RecordWithItems;
        })
      );
      setSelectedCustomer({ ...customer, vehicles, records: enrichedRecords });
    } catch (e) {
      notifyError('Failed to load customer details', String(e));
    }
  }, []);

  const handleDeleteCustomer = useCallback(async (id: string) => {
    if (!window.confirm('Delete this customer? This action cannot be undone.')) return;
    try {
      await api.deleteCustomer(id);
      notifySuccess('Customer deleted');
      await refreshCustomers();
    } catch (e) {
      notifyError('Failed to delete customer', String(e));
    }
  }, [refreshCustomers]);

  const handleDeleteVehicle = useCallback(async (id: string) => {
    if (!window.confirm('Delete this vehicle? This action cannot be undone.')) return;
    try {
      await api.deleteVehicle(id);
      notifySuccess('Vehicle deleted');
      await refreshVehicles();
      if (selectedCustomer) await loadCustomerDetails(selectedCustomer);
    } catch (e) {
      notifyError('Failed to delete vehicle', String(e));
    }
  }, [refreshVehicles, selectedCustomer, loadCustomerDetails]);

  const handleDeleteRecord = useCallback(async (id: string) => {
    if (!window.confirm('Delete this record? This action cannot be undone.')) return;
    try {
      await api.deleteRecord(id);
      notifySuccess('Record deleted');
      await refreshRecords();
      if (selectedCustomer) await loadCustomerDetails(selectedCustomer);
    } catch (e) {
      notifyError('Failed to delete record', String(e));
    }
  }, [refreshRecords, selectedCustomer, loadCustomerDetails]);

  const handleSaveCustomer = useCallback(async () => {
    if (!editData.name) {
      notifyError('Name is required');
      return;
    }
    try {
      const customerId = editData.id;
      if (customerId) {
        await api.updateCustomer(customerId, editData);
        notifySuccess('Customer updated');
      } else {
        await api.createCustomer(editData as any);
        notifySuccess('Customer created');
      }
      closeEdit();
      setEditData({});
      await refreshCustomers();
    } catch (e) {
      notifyError('Failed to save customer', String(e));
    }
  }, [editData, selectedCustomer?.id, refreshCustomers, closeEdit]);

  const handleSaveVehicle = useCallback(async () => {
    if (!vehicleData.machineId) {
      notifyError('Machine is required');
      return;
    }
    try {
      // Only send allowed fields (strip timestamps, id, etc.)
      const payload: Record<string, unknown> = {};
      if (vehicleData.machineId !== undefined) payload.machineId = vehicleData.machineId;
      if (vehicleData.licensePlate !== undefined) payload.licensePlate = vehicleData.licensePlate ?? null;
      if (vehicleData.frameNumber !== undefined) payload.frameNumber = vehicleData.frameNumber ?? null;
      if (vehicleData.colorId !== undefined) payload.colorId = vehicleData.colorId ?? null;
      if (vehicleData.year !== undefined) payload.year = vehicleData.year ?? null;
      if (vehicleData.nickname !== undefined) payload.nickname = vehicleData.nickname ?? null;
      if (vehicleData.notes !== undefined) payload.notes = vehicleData.notes ?? null;

      if (selectedVehicle?.id) {
        await api.updateVehicle(selectedVehicle.id, payload as any);
        notifySuccess('Vehicle updated');
      } else if (selectedCustomer?.id) {
        await api.createCustomerVehicle(selectedCustomer.id, payload as any);
        notifySuccess('Vehicle created');
      }
      closeVehicle();
      setVehicleData({});
      await refreshVehicles();
      if (selectedCustomer) {
        await loadCustomerDetails(selectedCustomer);
      }
    } catch (e) {
      notifyError('Failed to save vehicle', String(e));
    }
  }, [vehicleData, selectedVehicle, selectedCustomer, loadCustomerDetails, closeVehicle, refreshVehicles]);

  const handleSaveRecord = useCallback(async () => {
    if (!recordData.customerId || !recordData.description || !recordData.type) {
      notifyError('Customer, description, and type are required');
      return;
    }
    try {
      // Normalize date to epoch ms (handle both number and ISO string from API round-trip)
      const dateMs = recordData.date != null
        ? (typeof recordData.date === 'string' ? new Date(recordData.date).getTime() : recordData.date)
        : undefined;
      const payload = {
        customerId: recordData.customerId,
        customerVehicleId: recordData.customerVehicleId ?? null,
        type: recordData.type,
        date: dateMs,
        description: recordData.description,
        invoiceNumber: recordData.invoiceNumber ?? null,
        totalAmount: recordData.totalAmount ?? null,
        notes: recordData.notes ?? null,
      };
      if (selectedRecord?.id) {
        await api.updateRecord(selectedRecord.id, payload);
        notifySuccess('Record updated');
      } else {
        await api.createRecord(payload as any);
        notifySuccess('Record created');
      }
      closeRecord();
      setRecordData({});
      await refreshRecords();
      if (selectedCustomer) {
        await loadCustomerDetails(selectedCustomer);
      }
    } catch (e) {
      notifyError('Failed to save record', String(e));
    }
  }, [recordData, selectedRecord, selectedCustomer, loadCustomerDetails, closeRecord, refreshRecords]);

  const openEditCustomer = useCallback((customer?: Customer) => {
    setEditType('customer');
    setEditData(customer ? { id: customer.id, name: customer.name, phone: customer.phone, phoneAlt: customer.phoneAlt, email: customer.email, address: customer.address, notes: customer.notes, tag: customer.tag } : { name: '', phone: '', phoneAlt: '', email: '', address: '', notes: '', tag: '' });
    setSelectedCustomer(null);
    openEdit();
  }, [openEdit]);

  const openEditVehicle = useCallback((vehicle?: CustomerVehicle, customer?: Customer) => {
    setEditType('vehicle');
    // When editing from the vehicles tab, we might not have a customer context
    if (vehicle) {
      setVehicleData({
        machineId: vehicle.machineId,
        licensePlate: vehicle.licensePlate,
        frameNumber: vehicle.frameNumber,
        colorId: vehicle.colorId,
        year: vehicle.year,
        nickname: vehicle.nickname,
        notes: vehicle.notes,
      });
    } else {
      setVehicleData({ machineId: '', licensePlate: '', frameNumber: '', colorId: '', year: null, nickname: '', notes: '' });
    }
    refreshMachines();
    setSelectedVehicle(vehicle ?? null);
    if (customer) setSelectedCustomer(customer);
    openVehicle();
  }, [openVehicle, refreshMachines]);

  const openEditRecord = useCallback((record?: RecordWithItems | (MaintenanceRecord & { customerName?: string }), customer?: Customer) => {
    setEditType('record');
    if (record) {
      // Only pick editable fields — don't spread items, createdAt, updatedAt, etc.
      setRecordData({
        customerId: record.customerId,
        customerVehicleId: record.customerVehicleId,
        type: record.type,
        date: record.date,
        description: record.description,
        invoiceNumber: record.invoiceNumber,
        totalAmount: record.totalAmount,
        notes: record.notes,
      });
    } else {
      setRecordData({ customerId: customer?.id ?? '', type: 'service', description: '', date: Date.now() });
    }
    setSelectedRecord(record as RecordWithItems ?? null);
    if (customer) setSelectedCustomer(customer);
    openRecord();
  }, [openRecord]);

  // Customer rows
  const customerRows = filteredCustomers.map((c) => (
    <Table.Tr key={c.id} onClick={() => loadCustomerDetails(c)} style={{ cursor: 'pointer' }}>
      <Table.Td>
        <Group gap="sm">
          <IconUser size={18} />
          <Text fw={500}>{c.name}</Text>
        </Group>
      </Table.Td>
      <Table.Td>{c.phone ?? '-'}</Table.Td>
      <Table.Td>{c.email ?? '-'}</Table.Td>
      <Table.Td>{c.tag ? <Badge variant="light">{c.tag}</Badge> : '-'}</Table.Td>
      <Table.Td>-</Table.Td>
      <Table.Td>-</Table.Td>
      <Table.Td>
        <Group gap="xs">
          <ActionIcon size="sm" variant="subtle" onClick={(e) => { e.stopPropagation(); openEditCustomer(c); }}>
            <IconEdit size={16} />
          </ActionIcon>
          <ActionIcon size="sm" variant="subtle" color="red" onClick={(e) => { e.stopPropagation(); handleDeleteCustomer(c.id); }}>
            <IconTrash size={16} />
          </ActionIcon>
        </Group>
      </Table.Td>
    </Table.Tr>
  ));

  // --- Vehicle rows (for Vehicles tab) ---
  const vehicleRows = allVehicles.map((v) => (
    <Table.Tr key={v.id}>
      <Table.Td>
        <Group gap="sm">
          <IconBike size={16} />
          <Text fw={500}>{v.nickname || `${v.machineBrand} ${v.machineModel}`}</Text>
        </Group>
      </Table.Td>
      <Table.Td>{v.customerName}</Table.Td>
      <Table.Td>{v.licensePlate ?? '-'}</Table.Td>
      <Table.Td>{v.frameNumber ?? '-'}</Table.Td>
      <Table.Td>{v.year ?? '-'}</Table.Td>
      <Table.Td>
        <Group gap="xs">
          <ActionIcon size="sm" variant="subtle" onClick={() => {
            // Open edit modal — we pass the vehicle without customer context since we're in the standalone tab
            setSelectedVehicle(v);
            openEditVehicle(v);
          }}>
            <IconEdit size={14} />
          </ActionIcon>
          <ActionIcon size="sm" variant="subtle" color="red" onClick={() => handleDeleteVehicle(v.id)}>
            <IconTrash size={14} />
          </ActionIcon>
        </Group>
      </Table.Td>
    </Table.Tr>
  ));

  // --- Record rows (for Records tab) ---
  const recordRows = filteredRecords.map((r) => (
    <Table.Tr key={r.id}>
      <Table.Td>{r.customerName}</Table.Td>
      <Table.Td>
        <Badge variant="light" color={r.type === 'service' ? 'blue' : 'green'}>
          {r.type}
        </Badge>
      </Table.Td>
      <Table.Td>{new Date(r.date).toISOString().split('T')[0]}</Table.Td>
      <Table.Td>{r.description}</Table.Td>
      <Table.Td>{r.invoiceNumber ?? '-'}</Table.Td>
      <Table.Td>{r.totalAmount ? r.totalAmount.toLocaleString() : '-'}</Table.Td>
      <Table.Td>
        <Group gap="xs">
          <ActionIcon size="sm" variant="subtle" onClick={() => openEditRecord(r)}>
            <IconEdit size={14} />
          </ActionIcon>
          <ActionIcon size="sm" variant="subtle" color="red" onClick={() => handleDeleteRecord(r.id)}>
            <IconTrash size={14} />
          </ActionIcon>
        </Group>
      </Table.Td>
    </Table.Tr>
  ));

  // Customer detail panel
  const customerDetail = selectedCustomer && (
    <Paper withBorder p="md" mt="md">
      <Group justify="space-between" align="center" mb="md">
        <Title order={4}>{selectedCustomer.name}</Title>
        <Group gap="xs">
          <Button size="xs" leftSection={<IconPlus size={14} />} onClick={() => openEditVehicle(undefined, selectedCustomer)}>
            Add Vehicle
          </Button>
          <Button size="xs" leftSection={<IconPlus size={14} />} onClick={() => openEditRecord(undefined, selectedCustomer)}>
            Add Record
          </Button>
          <ActionIcon size="sm" variant="subtle" onClick={() => { setSelectedCustomer(null); setSelectedVehicle(null); setSelectedRecord(null); }}>
            <IconX size={16} />
          </ActionIcon>
        </Group>
      </Group>

      <Divider my="sm" />

      {/* Customer info */}
      <Stack gap="xs" mb="md">
        <Group gap="md">
          <Text size="sm" c="dimmed" w={120}>Phone</Text>
          <Text size="sm">{selectedCustomer.phone ?? '-'}</Text>
        </Group>
        <Group gap="md">
          <Text size="sm" c="dimmed" w={120}>Phone (Alt)</Text>
          <Text size="sm">{selectedCustomer.phoneAlt ?? '-'}</Text>
        </Group>
        <Group gap="md">
          <Text size="sm" c="dimmed" w={120}>Email</Text>
          <Text size="sm">{selectedCustomer.email ?? '-'}</Text>
        </Group>
        <Group gap="md">
          <Text size="sm" c="dimmed" w={120}>Address</Text>
          <Text size="sm">{selectedCustomer.address ?? '-'}</Text>
        </Group>
        <Group gap="md">
          <Text size="sm" c="dimmed" w={120}>Tag</Text>
          {selectedCustomer.tag ? <Badge variant="light">{selectedCustomer.tag}</Badge> : <Text size="sm">-</Text>}
        </Group>
        <Group gap="md">
          <Text size="sm" c="dimmed" w={120}>Notes</Text>
          <Text size="sm">{selectedCustomer.notes ?? '-'}</Text>
        </Group>
      </Stack>

      {/* Vehicles */}
      {selectedCustomer.vehicles && selectedCustomer.vehicles.length > 0 && (
        <>
          <Title order={5} mt="md">Vehicles ({selectedCustomer.vehicles.length})</Title>
          <ScrollArea>
            <Table striped highlightOnHover>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Machine</Table.Th>
                  <Table.Th>License Plate</Table.Th>
                  <Table.Th>Frame Number</Table.Th>
                  <Table.Th>Year</Table.Th>
                  <Table.Th>Nickname</Table.Th>
                  <Table.Th>Records</Table.Th>
                  <Table.Th>Actions</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {selectedCustomer.vehicles.map((v: CustomerVehicle) => (
                  <Table.Tr key={v.id} onClick={() => setSelectedVehicle(v)} style={{ cursor: 'pointer' }}>
                    <Table.Td>
                      <Group gap="sm">
                        <IconBike size={16} />
                        <Text>
                          {(() => {
                            const m = machines.find((m) => m.id === v.machineId);
                            return m ? `${m.brand} ${m.model}` : v.machineId;
                          })()}
                        </Text>
                      </Group>
                    </Table.Td>
                    <Table.Td>{v.licensePlate ?? '-'}</Table.Td>
                    <Table.Td>{v.frameNumber ?? '-'}</Table.Td>
                    <Table.Td>{v.year ?? '-'}</Table.Td>
                    <Table.Td>{v.nickname ?? '-'}</Table.Td>
                    <Table.Td>-</Table.Td>
                    <Table.Td>
                      <Group gap="xs">
                        <ActionIcon size="sm" variant="subtle" onClick={(e) => { e.stopPropagation(); openEditVehicle(v, selectedCustomer); }}>
                          <IconEdit size={14} />
                        </ActionIcon>
                        <ActionIcon size="sm" variant="subtle" color="red" onClick={(e) => { e.stopPropagation(); handleDeleteVehicle(v.id); }}>
                          <IconTrash size={14} />
                        </ActionIcon>
                      </Group>
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          </ScrollArea>
        </>
      )}

      {/* Records */}
      {selectedCustomer.records && selectedCustomer.records.length > 0 && (
        <>
          <Title order={5} mt="md">Maintenance Records ({selectedCustomer.records.length})</Title>
          <ScrollArea>
            <Table striped highlightOnHover>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Type</Table.Th>
                  <Table.Th>Date</Table.Th>
                  <Table.Th>Description</Table.Th>
                  <Table.Th>Invoice</Table.Th>
                  <Table.Th>Amount</Table.Th>
                  <Table.Th>Items</Table.Th>
                  <Table.Th>Actions</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {(selectedCustomer.records as RecordWithItems[] ?? []).map((r) => (
                  <Table.Tr key={r.id} onClick={() => setSelectedRecord(r)} style={{ cursor: 'pointer' }}>
                    <Table.Td>
                      <Badge variant="light" color={r.type === 'service' ? 'blue' : 'green'}>
                        {r.type}
                      </Badge>
                    </Table.Td>
                    <Table.Td>{new Date(r.date).toISOString().split('T')[0]}</Table.Td>
                    <Table.Td>{r.description}</Table.Td>
                    <Table.Td>{r.invoiceNumber ?? '-'}</Table.Td>
                    <Table.Td>{r.totalAmount ? r.totalAmount.toLocaleString() : '-'}</Table.Td>
                    <Table.Td>{r.items?.length ?? 0}</Table.Td>
                    <Table.Td>
                      <Group gap="xs">
                        <ActionIcon size="sm" variant="subtle" onClick={(e) => { e.stopPropagation(); openEditRecord(r, selectedCustomer); }}>
                          <IconEdit size={14} />
                        </ActionIcon>
                        <ActionIcon size="sm" variant="subtle" color="red" onClick={(e) => { e.stopPropagation(); handleDeleteRecord(r.id); }}>
                          <IconTrash size={14} />
                        </ActionIcon>
                      </Group>
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
            </Table>
          </ScrollArea>
        </>
      )}
    </Paper>
  );

  return (
    <Stack gap="md">
      <Group justify="space-between" align="center">
        <Title order={3}>Customer Relationship Management</Title>
        <Button leftSection={<IconPlus size={18} />} onClick={() => openEditCustomer()}>
          Add Customer
        </Button>
      </Group>

      <Tabs value={tab} onChange={(v) => setTab(v as TabType)} keepMounted={false}>
        <Tabs.List>
          <Tabs.Tab value="customers" leftSection={<IconUser size={16} />}>
            Customers
          </Tabs.Tab>
          <Tabs.Tab value="vehicles" leftSection={<IconBike size={16} />}>
            Vehicles
          </Tabs.Tab>
          <Tabs.Tab value="records" leftSection={<IconEdit size={16} />}>
            Records
          </Tabs.Tab>
        </Tabs.List>

        {/* --- CUSTOMERS TAB --- */}
        <Tabs.Panel value="customers" pt="md">
          <TextInput
            placeholder="Search customers..."
            value={search}
            onChange={(e) => setSearch(e.currentTarget.value)}
            leftSection={<IconUser size={16} />}
            mb="md"
          />
          <ScrollArea>
            <Table striped highlightOnHover>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Name</Table.Th>
                  <Table.Th>Phone</Table.Th>
                  <Table.Th>Email</Table.Th>
                  <Table.Th>Tag</Table.Th>
                  <Table.Th>Vehicles</Table.Th>
                  <Table.Th>Records</Table.Th>
                  <Table.Th>Actions</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>{customerRows}</Table.Tbody>
            </Table>
          </ScrollArea>
          {customerDetail}
        </Tabs.Panel>

        {/* --- VEHICLES TAB --- */}
        <Tabs.Panel value="vehicles" pt="md">
          <TextInput
            placeholder="Search vehicles by customer, plate, frame, or nickname..."
            value={vehicleSearch}
            onChange={(e) => setVehicleSearch(e.currentTarget.value)}
            onKeyDown={(e) => { if (e.key === 'Enter') refreshVehicles(); }}
            leftSection={<IconBike size={16} />}
            mb="md"
          />
          <ScrollArea>
            <Table striped highlightOnHover>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Vehicle</Table.Th>
                  <Table.Th>Customer</Table.Th>
                  <Table.Th>License Plate</Table.Th>
                  <Table.Th>Frame Number</Table.Th>
                  <Table.Th>Year</Table.Th>
                  <Table.Th>Actions</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {allVehicles.length === 0 ? (
                  <Table.Tr>
                    <Table.Td colSpan={6}>
                      <Text c="dimmed" ta="center" py="md">No vehicles found. Add vehicles from the Customers tab.</Text>
                    </Table.Td>
                  </Table.Tr>
                ) : (
                  vehicleRows
                )}
              </Table.Tbody>
            </Table>
          </ScrollArea>
        </Tabs.Panel>

        {/* --- RECORDS TAB --- */}
        <Tabs.Panel value="records" pt="md">
          <Group mb="md">
            <TextInput
              placeholder="Search records by customer, description, invoice..."
              value={recordSearch}
              onChange={(e) => setRecordSearch(e.currentTarget.value)}
              leftSection={<IconEdit size={16} />}
              style={{ flex: 1 }}
            />
            <Select
              placeholder="All types"
              data={[
                { value: '', label: 'All types' },
                { value: 'service', label: 'Service' },
                { value: 'purchase', label: 'Purchase' },
              ]}
              value={recordTypeFilter}
              onChange={(v) => setRecordTypeFilter(v || null)}
              w={140}
              clearable
            />
          </Group>
          <ScrollArea>
            <Table striped highlightOnHover>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Customer</Table.Th>
                  <Table.Th>Type</Table.Th>
                  <Table.Th>Date</Table.Th>
                  <Table.Th>Description</Table.Th>
                  <Table.Th>Invoice</Table.Th>
                  <Table.Th>Amount</Table.Th>
                  <Table.Th>Actions</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {filteredRecords.length === 0 ? (
                  <Table.Tr>
                    <Table.Td colSpan={7}>
                      <Text c="dimmed" ta="center" py="md">
                        {allRecords.length === 0
                          ? 'No records found. Add records from the Customers tab.'
                          : 'No records match your search.'}
                      </Text>
                    </Table.Td>
                  </Table.Tr>
                ) : (
                  recordRows
                )}
              </Table.Tbody>
            </Table>
          </ScrollArea>
        </Tabs.Panel>
      </Tabs>

      {/* Customer Edit Modal */}
      <Modal opened={editModalOpened && editType === 'customer'} onClose={closeEdit} title="Edit Customer" size="lg">
        <Stack gap="md">
          <TextInput
            label="Name *"
            value={editData.name ?? ''}
            onChange={(e) => setEditData({ ...editData, name: e.currentTarget.value })}
            placeholder="Customer name"
          />
          <TextInput
            label="Phone"
            value={editData.phone ?? ''}
            onChange={(e) => setEditData({ ...editData, phone: e.currentTarget.value })}
            placeholder="Phone number"
          />
          <TextInput
            label="Phone (Alternate)"
            value={editData.phoneAlt ?? ''}
            onChange={(e) => setEditData({ ...editData, phoneAlt: e.currentTarget.value })}
            placeholder="Alternate phone"
          />
          <TextInput
            label="Email"
            value={editData.email ?? ''}
            onChange={(e) => setEditData({ ...editData, email: e.currentTarget.value })}
            placeholder="Email address"
          />
          <TextInput
            label="Address"
            value={editData.address ?? ''}
            onChange={(e) => setEditData({ ...editData, address: e.currentTarget.value })}
            placeholder="Address"
          />
          <TextInput
            label="Tag"
            value={editData.tag ?? ''}
            onChange={(e) => setEditData({ ...editData, tag: e.currentTarget.value })}
            placeholder="Tag"
          />
          <TextInput
            label="Notes"
            value={editData.notes ?? ''}
            onChange={(e) => setEditData({ ...editData, notes: e.currentTarget.value })}
            placeholder="Additional notes"
          />
          <Group justify="flex-end" mt="md">
            <Button variant="default" onClick={closeEdit}>
              Cancel
            </Button>
            <Button onClick={handleSaveCustomer}>
              Save
            </Button>
          </Group>
        </Stack>
      </Modal>

      {/* Vehicle Edit Modal */}
      <Modal opened={vehicleModalOpened} onClose={closeVehicle} title="Edit Vehicle" size="lg">
        <Stack gap="md">
          <Select
            label="Machine *"
            value={vehicleData.machineId || null}
            onChange={(v) => setVehicleData({ ...vehicleData, machineId: v ?? '' })}
            placeholder="Select a machine"
            data={machines.map((m) => ({ value: m.id, label: `${m.brand} ${m.model}` }))}
            searchable
            nothingFoundMessage="No machines found — create one in Browse"
            clearable
          />
          <TextInput
            label="License Plate"
            value={vehicleData.licensePlate ?? ''}
            onChange={(e) => setVehicleData({ ...vehicleData, licensePlate: e.currentTarget.value })}
            placeholder="License plate"
          />
          <TextInput
            label="Frame Number"
            value={vehicleData.frameNumber ?? ''}
            onChange={(e) => setVehicleData({ ...vehicleData, frameNumber: e.currentTarget.value })}
            placeholder="Frame number"
          />
          <TextInput
            label="Color ID"
            value={vehicleData.colorId ?? ''}
            onChange={(e) => setVehicleData({ ...vehicleData, colorId: e.currentTarget.value })}
            placeholder="Color ID"
          />
          <TextInput
            label="Year"
            value={vehicleData.year ?? ''}
            onChange={(e) => setVehicleData({ ...vehicleData, year: e.currentTarget.value ? Number(e.currentTarget.value) : undefined })}
            placeholder="Year"
            type="number"
          />
          <TextInput
            label="Nickname"
            value={vehicleData.nickname ?? ''}
            onChange={(e) => setVehicleData({ ...vehicleData, nickname: e.currentTarget.value })}
            placeholder="Nickname"
          />
          <TextInput
            label="Notes"
            value={vehicleData.notes ?? ''}
            onChange={(e) => setVehicleData({ ...vehicleData, notes: e.currentTarget.value })}
            placeholder="Notes"
          />
          <Group justify="flex-end" mt="md">
            <Button variant="default" onClick={closeVehicle}>
              Cancel
            </Button>
            <Button onClick={handleSaveVehicle}>
              Save
            </Button>
          </Group>
        </Stack>
      </Modal>

      {/* Record Edit Modal */}
      <Modal opened={recordModalOpened} onClose={closeRecord} title="Edit Maintenance Record" size="lg">
        <Stack gap="md">
          <TextInput
            label="Customer ID *"
            value={recordData.customerId ?? ''}
            onChange={(e) => setRecordData({ ...recordData, customerId: e.currentTarget.value })}
            placeholder="Customer ID"
            disabled
          />
          <Select
            label="Vehicle"
            data={recordVehicles.map((v) => {
              const m = machines.find((x) => x.id === v.machineId);
              const mName = m ? `${m.brand} ${m.model}` : v.machineId;
              let label = mName;
              if (v.nickname && v.licensePlate) {
                label = `${v.nickname} : ${mName} - ${v.licensePlate}`;
              } else if (v.nickname) {
                label = `${v.nickname} : ${mName}`;
              } else if (v.licensePlate) {
                label = `${mName} - ${v.licensePlate}`;
              }
              return { value: v.id, label };
            })}
            value={recordData.customerVehicleId || null}
            onChange={(v) => setRecordData({ ...recordData, customerVehicleId: v ?? '' })}
            placeholder="Select a vehicle (optional)"
            clearable
            renderOption={({ option }) => (
              <Stack gap={0}>
                <Text size="sm">{option.label}</Text>
                <Text size="xs" c="dimmed">{option.value}</Text>
              </Stack>
            )}
          />
          <Select
            label="Type *"
            data={[
              { value: 'service', label: 'Service' },
              { value: 'purchase', label: 'Purchase' },
            ]}
            value={recordData.type ?? ''}
            onChange={(v) => setRecordData({ ...recordData, type: (v as 'service' | 'purchase') ?? 'service' })}
            placeholder="Select type"
          />
          <TextInput
            label="Description *"
            value={recordData.description ?? ''}
            onChange={(e) => setRecordData({ ...recordData, description: e.currentTarget.value })}
            placeholder="Description"
          />
          <TextInput
            label="Date"
            value={recordData.date ? new Date(recordData.date).toISOString().split('T')[0] : ''}
            onChange={(e) => setRecordData({ ...recordData, date: new Date(e.currentTarget.value).getTime() })}
            placeholder="YYYY-MM-DD"
            type="date"
          />
          <TextInput
            label="Invoice Number"
            value={recordData.invoiceNumber ?? ''}
            onChange={(e) => setRecordData({ ...recordData, invoiceNumber: e.currentTarget.value })}
            placeholder="Invoice number"
          />
          <NumberInput
            label="Total Amount"
            value={recordData.totalAmount ?? ''}
            onChange={(val) => setRecordData({ ...recordData, totalAmount: typeof val === 'number' ? val : undefined })}
            placeholder="Amount"
            thousandSeparator=","
            hideControls
          />
          <TextInput
            label="Notes"
            value={recordData.notes ?? ''}
            onChange={(e) => setRecordData({ ...recordData, notes: e.currentTarget.value })}
            placeholder="Notes"
          />
          <Group justify="flex-end" mt="md">
            <Button variant="default" onClick={closeRecord}>
              Cancel
            </Button>
            <Button onClick={handleSaveRecord}>
              Save
            </Button>
          </Group>
        </Stack>
      </Modal>
    </Stack>
  );
}

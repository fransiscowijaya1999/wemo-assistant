import { useState } from 'react';
import {
  ActionIcon,
  Badge,
  Button,
  Card,
  Group,
  Modal,
  Paper,
  Stack,
  Text,
  TextInput,
  ThemeIcon,
  Title,
} from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import {
  IconArrowsExchange,
  IconPlus,
  IconSearch,
  IconStar,
  IconStarFilled,
  IconX,
} from '@tabler/icons-react';
import { api } from './api';
import { notifyError, notifySuccess } from './notify';
import type { PartFull, SearchResult } from './types';

// A reusable part picker: search by number/name/alias, pick one candidate.
function PartPicker({
  label,
  placeholder,
  onPick,
  onCreateNew,
  excludeId,
}: {
  label: string;
  placeholder: string;
  onPick: (partId: string) => void;
  onCreateNew?: () => void;
  excludeId?: string;
}) {
  const [q, setQ] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [state, setState] = useState<'idle' | 'loading' | 'notfound'>('idle');

  async function search() {
    if (!q.trim()) return;
    setResults([]);
    setState('loading');
    try {
      const { results } = await api.searchParts(q.trim());
      const filtered = results.filter((r) => r.partId !== excludeId);
      setResults(filtered);
      setState(filtered.length === 0 ? 'notfound' : 'idle');
    } catch (e) {
      setState('idle');
      notifyError('Search failed', String(e));
    }
  }

  return (
    <Stack gap="xs">
      <Group align="flex-end">
        <TextInput
          label={label}
          placeholder={placeholder}
          value={q}
          onChange={(e) => setQ(e.currentTarget.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') void search();
          }}
          w={320}
        />
        <Button
          leftSection={<IconSearch size={16} />}
          onClick={search}
          disabled={!q.trim()}
          loading={state === 'loading'}
        >
          Search
        </Button>
      </Group>
      {state === 'notfound' && (
        <Group gap="xs">
          <Text size="sm" c="dimmed">
            No matches found. Try fewer characters, or create a new part record.
          </Text>
          {onCreateNew && (
            <Button size="compact-xs" variant="light" color="wemo" leftSection={<IconPlus size={12} />} onClick={onCreateNew}>
              Create new part
            </Button>
          )}
        </Group>
      )}
      {results.length > 0 && (
        <Group gap={6}>
          {results.map((r) => (
            <Button
              key={r.partId}
              size="compact-xs"
              variant="light"
              onClick={() => {
                onPick(r.partId);
                setQ('');
                setResults([]);
                setState('idle');
              }}
            >
              {r.primaryNumber ? `${r.primaryNumber} · ` : ''}
              {r.name}
            </Button>
          ))}
        </Group>
      )}
    </Stack>
  );
}

export function SubstitutesView() {
  const [part, setPart] = useState<PartFull | null>(null);
  const [note, setNote] = useState('');
  const [busy, setBusy] = useState(false);
  const [createOpened, { open: openCreate, close: closeCreate }] = useDisclosure(false);

  // New Part form state
  const [newNumber, setNewNumber] = useState('');
  const [newName, setNewName] = useState('');
  const [newBrand, setNewBrand] = useState('');
  const [newCategory, setNewCategory] = useState('');
  const [creating, setCreating] = useState(false);

  async function handleCreatePart() {
    if (!newNumber.trim() || !newName.trim()) return;
    setCreating(true);
    try {
      const res = await api.createPart({
        partNumber: newNumber.trim(),
        nameRaw: newName.trim(),
        brand: newBrand.trim() || undefined,
        category: newCategory.trim() || undefined,
      });
      notifySuccess('Part created', `${newNumber} (${newName}) has been added.`);
      closeCreate();
      setNewNumber('');
      setNewName('');
      setNewBrand('');
      setNewCategory('');

      // Auto-load or link the created part
      if (!part) {
        await load(res.partId);
      } else {
        await addLink(res.partId);
      }
    } catch (e) {
      notifyError('Could not create part', String(e));
    } finally {
      setCreating(false);
    }
  }

  async function load(id: string) {
    try {
      setPart(await api.getPart(id));
    } catch (e) {
      notifyError('Could not load part', String(e));
    }
  }

  async function addLink(otherId: string) {
    if (!part) return;
    setBusy(true);
    try {
      await api.addSubstitute(part.id, otherId, note.trim() || undefined);
      notifySuccess('Substitute linked', 'Each part now lists the other.');
      setNote('');
      await load(part.id);
    } catch (e) {
      notifyError('Could not link', String(e));
    } finally {
      setBusy(false);
    }
  }

  async function removeLink(otherId: string) {
    if (!part) return;
    setBusy(true);
    try {
      await api.removeSubstitute(part.id, otherId);
      notifySuccess('Substitute unlinked');
      await load(part.id);
    } catch (e) {
      notifyError('Could not unlink', String(e));
    } finally {
      setBusy(false);
    }
  }

  // Mark a part (the managed one or one of its substitutes) as the current
  // replacement. The backend auto-clears the flag on its cluster siblings, so
  // exactly one part stays current; reload to reflect the moved highlight.
  async function setCurrent(id: string, makeCurrent: boolean) {
    if (!part) return;
    setBusy(true);
    try {
      if (makeCurrent) await api.markCurrent(id);
      else await api.unmarkCurrent(id);
      notifySuccess(makeCurrent ? 'Marked as current replacement' : 'Cleared current replacement');
      await load(part.id);
    } catch (e) {
      notifyError('Could not update', String(e));
    } finally {
      setBusy(false);
    }
  }

  const partName = part ? part.nameNormalized ?? part.nameRaw : '';

  return (
    <Stack>
      <Modal opened={createOpened} onClose={closeCreate} title="Create New Canonical Part" centered>
        <Stack gap="sm">
          <TextInput
            label="Part Number"
            placeholder="e.g. 6201 2RS or NSK 6201 DDU"
            required
            value={newNumber}
            onChange={(e) => setNewNumber(e.currentTarget.value)}
          />
          <TextInput
            label="Part Name"
            placeholder="e.g. Bearing 6201 2RS (Laher 6201)"
            required
            value={newName}
            onChange={(e) => setNewName(e.currentTarget.value)}
          />
          <Group grow>
            <TextInput
              label="Brand (optional)"
              placeholder="e.g. NSK, NTN, Generic"
              value={newBrand}
              onChange={(e) => setNewBrand(e.currentTarget.value)}
            />
            <TextInput
              label="Category (optional)"
              placeholder="e.g. Bearing"
              value={newCategory}
              onChange={(e) => setNewCategory(e.currentTarget.value)}
            />
          </Group>
          <Group justify="flex-end" mt="md">
            <Button variant="default" onClick={closeCreate}>
              Cancel
            </Button>
            <Button
              color="wemo"
              onClick={handleCreatePart}
              loading={creating}
              disabled={!newNumber.trim() || !newName.trim()}
            >
              Create Part
            </Button>
          </Group>
        </Stack>
      </Modal>

      <Card withBorder>
        <Stack gap="sm">
          <Group justify="space-between" align="center">
            <Group gap="xs">
              <ThemeIcon variant="light" size="sm">
                <IconArrowsExchange size={14} />
              </ThemeIcon>
              <Title order={5}>Substitute parts</Title>
            </Group>
            <Button
              size="xs"
              variant="light"
              color="wemo"
              leftSection={<IconPlus size={14} />}
              onClick={openCreate}
            >
              Create New Part
            </Button>
          </Group>
          <Text size="sm" c="dimmed">
            Link two different parts that can replace each other (e.g. OEM 91001-KCW-870 ↔ generic 6201 2RS). The
            link is mutual — each part shows the other as a substitute, and you can mark a preferred standard part as the <strong>Current Replacement</strong>.
          </Text>
          <PartPicker
            label="Pick a part to manage"
            placeholder="e.g. 91001-KCW-870, 6201 2RS, or “bearing”"
            onPick={load}
            onCreateNew={openCreate}
          />
        </Stack>
      </Card>

      {part && (
        <Card withBorder>
          <Stack gap="sm">
            <div>
              <Group gap="sm">
                <Text fw={600}>{partName}</Text>
                <Button
                  size="compact-xs"
                  variant={part.isCurrentReplacement ? 'filled' : 'default'}
                  color="yellow"
                  leftSection={
                    part.isCurrentReplacement ? <IconStarFilled size={12} /> : <IconStar size={12} />
                  }
                  disabled={busy}
                  onClick={() => setCurrent(part.id, !part.isCurrentReplacement)}
                >
                  {part.isCurrentReplacement ? 'Current replacement' : 'Mark as current'}
                </Button>
              </Group>
              <Group gap="xs" mt={4}>
                {part.numbers.map((n) => (
                  <Badge
                    key={n.value}
                    variant={n.isPrimary ? 'filled' : 'light'}
                    color={n.kind === 'oem' ? 'wemo' : 'gray'}
                  >
                    {n.value}
                  </Badge>
                ))}
              </Group>
            </div>

            <div>
              <Text size="xs" c="dimmed" fw={500} mb={4}>
                Substitutes ({part.substitutes.length})
              </Text>
              {part.substitutes.length === 0 ? (
                <Text size="sm" c="dimmed">
                  None yet. Add one below.
                </Text>
              ) : (
                <Stack gap={6}>
                  <Group gap={6}>
                    {part.substitutes.map((s) => (
                      <Badge
                        key={s.partId}
                        size="lg"
                        variant={s.isCurrent ? 'filled' : 'light'}
                        color={s.isCurrent ? 'yellow' : 'teal'}
                        leftSection={s.isCurrent ? <IconStarFilled size={11} /> : undefined}
                        rightSection={
                          <Group gap={2} wrap="nowrap">
                            {!s.isCurrent && (
                              <ActionIcon
                                size="xs"
                                color="yellow"
                                variant="transparent"
                                aria-label={`Mark ${s.name} as current replacement`}
                                title="Mark as current replacement"
                                disabled={busy}
                                onClick={() => setCurrent(s.partId, true)}
                              >
                                <IconStar size={12} />
                              </ActionIcon>
                            )}
                            <ActionIcon
                              size="xs"
                              color={s.isCurrent ? 'yellow.9' : 'teal'}
                              variant="transparent"
                              aria-label={`Remove ${s.name}`}
                              disabled={busy}
                              onClick={() => removeLink(s.partId)}
                            >
                              <IconX size={12} />
                            </ActionIcon>
                          </Group>
                        }
                      >
                        {s.primaryNumber ? `${s.primaryNumber} · ` : ''}
                        {s.name}
                      </Badge>
                    ))}
                  </Group>
                  <Text size="xs" c="dimmed">
                    ★ marks the current replacement — the part to use; the others are obsolete. Click
                    the star on a substitute to make it current.
                  </Text>
                </Stack>
              )}
            </div>

            <Paper withBorder p="sm" bg="var(--mantine-color-default-hover)">
              <Stack gap="xs">
                <Group gap="xs">
                  <ThemeIcon variant="light" size="sm" color="teal">
                    <IconPlus size={14} />
                  </ThemeIcon>
                  <Text fw={500} size="sm">
                    Add a substitute for “{partName}”
                  </Text>
                </Group>
                <TextInput
                  label="Note (optional)"
                  placeholder="e.g. same fitment, newer casting"
                  value={note}
                  onChange={(e) => setNote(e.currentTarget.value)}
                  w={320}
                />
                <PartPicker
                  label="Find the other part"
                  placeholder="Search by number, name or alias"
                  onPick={addLink}
                  onCreateNew={openCreate}
                  excludeId={part.id}
                />
              </Stack>
            </Paper>
          </Stack>
        </Card>
      )}
    </Stack>
  );
}

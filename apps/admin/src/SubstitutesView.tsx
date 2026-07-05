import { useState } from 'react';
import {
  ActionIcon,
  Badge,
  Button,
  Card,
  Group,
  Paper,
  Stack,
  Text,
  TextInput,
  ThemeIcon,
  Title,
} from '@mantine/core';
import { IconArrowsExchange, IconPlus, IconSearch, IconX } from '@tabler/icons-react';
import { api } from './api';
import { notifyError, notifySuccess } from './notify';
import type { PartFull, SearchResult } from './types';

// A reusable part picker: search by number/name/alias, pick one candidate.
function PartPicker({
  label,
  placeholder,
  onPick,
  excludeId,
}: {
  label: string;
  placeholder: string;
  onPick: (partId: string) => void;
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
        <Text size="sm" c="dimmed">
          No matches. Try fewer characters of the number (dashes optional), or a name/alias.
        </Text>
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

  const partName = part ? part.nameNormalized ?? part.nameRaw : '';

  return (
    <Stack>
      <Card withBorder>
        <Stack gap="sm">
          <Group gap="xs">
            <ThemeIcon variant="light" size="sm">
              <IconArrowsExchange size={14} />
            </ThemeIcon>
            <Title order={5}>Substitute parts</Title>
          </Group>
          <Text size="sm" c="dimmed">
            Link two different parts that can replace each other (e.g. 12000-KWB ↔ 12000-KYZ). The
            link is mutual — each part shows the other as a substitute. This does not merge them:
            both keep their own numbers, diagrams and aliases.
          </Text>
          <PartPicker
            label="Pick a part to manage"
            placeholder="e.g. 12000-KWB, or “cylinder”"
            onPick={load}
          />
        </Stack>
      </Card>

      {part && (
        <Card withBorder>
          <Stack gap="sm">
            <div>
              <Text fw={600}>{partName}</Text>
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
                Current substitutes ({part.substitutes.length})
              </Text>
              {part.substitutes.length === 0 ? (
                <Text size="sm" c="dimmed">
                  None yet. Add one below.
                </Text>
              ) : (
                <Group gap={6}>
                  {part.substitutes.map((s) => (
                    <Badge
                      key={s.partId}
                      size="lg"
                      variant="light"
                      color="teal"
                      rightSection={
                        <ActionIcon
                          size="xs"
                          color="teal"
                          variant="transparent"
                          aria-label={`Remove ${s.name}`}
                          disabled={busy}
                          onClick={() => removeLink(s.partId)}
                        >
                          <IconX size={12} />
                        </ActionIcon>
                      }
                    >
                      {s.primaryNumber ? `${s.primaryNumber} · ` : ''}
                      {s.name}
                    </Badge>
                  ))}
                </Group>
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

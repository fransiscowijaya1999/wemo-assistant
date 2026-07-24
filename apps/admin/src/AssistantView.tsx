import { useRef, useState } from 'react';
import {
  ActionIcon,
  Badge,
  Box,
  Button,
  Card,
  Group,
  Paper,
  ScrollArea,
  Stack,
  Table,
  Text,
  Textarea,
  ThemeIcon,
  Title,
} from '@mantine/core';
import { IconArrowRight, IconCheck, IconRobot, IconSend, IconSparkles, IconX } from '@tabler/icons-react';
import { api } from './api';
import { Markdown } from './Markdown';
import { notifyError, notifySuccess } from './notify';
import type { ChatMessage, Proposal } from './types';

type Status = 'pending' | 'applied' | 'rejected' | 'error';
type TrackedProposal = Proposal & { status: Status; error?: string };

const TYPE_LABEL: Record<string, string> = {
  rename: 'Rename / normalize',
  add_alias: 'Add alias',
  add_number: 'Add number',
  edit_number: 'Edit number',
  merge: 'Merge duplicate',
  substitute: 'Link substitutes',
};

const SUGGESTIONS = [
  'Normalize the name of part 12200-KVY-900',
  'Add the Indonesian alias "paking kepala" to the cylinder head gasket',
  'Find parts whose name is still in raw ALL-CAPS catalog form',
];

function fmt(v: unknown): string {
  if (v === null || v === undefined || v === '') return '—';
  return String(v);
}

function ProposalCard({ p, onApprove, onReject }: { p: TrackedProposal; onApprove: () => void; onReject: () => void }) {
  const isMerge = p.proposal.type === 'merge';
  const keys = [...new Set([...Object.keys(p.before ?? {}), ...Object.keys(p.after ?? {})])];
  return (
    <Card withBorder radius="md" padding="sm">
      <Stack gap="xs">
        <Group justify="space-between" align="flex-start" wrap="nowrap">
          <Box>
            <Group gap={6}>
              <Badge size="sm" variant="light" color={isMerge ? 'orange' : undefined}>
                {TYPE_LABEL[p.proposal.type] ?? p.proposal.type}
              </Badge>
              <Text fw={600} size="sm">
                {p.summary}
              </Text>
            </Group>
            {!isMerge && (
              <Text size="xs" c="dimmed" ff="monospace">
                {p.partLabel}
              </Text>
            )}
          </Box>
          {p.status === 'applied' && <Badge color="green" leftSection={<IconCheck size={12} />}>Applied</Badge>}
          {p.status === 'rejected' && <Badge color="gray">Rejected</Badge>}
          {p.status === 'error' && <Badge color="red">Failed</Badge>}
        </Group>

        {isMerge && (
          <Box p="xs" style={{ background: 'var(--mantine-color-orange-light)', borderRadius: 6 }}>
            <Text size="xs" c="dimmed">
              Remove (its data moves over)
            </Text>
            <Text size="sm" td="line-through" c="dimmed" ff="monospace">
              {String(p.before?.remove ?? '')}
            </Text>
            <Group gap={6} mt={4} align="center">
              <IconArrowRight size={14} />
              <Text size="xs" c="dimmed">
                Keep
              </Text>
            </Group>
            <Text size="sm" fw={600} ff="monospace">
              {String(p.after?.keep ?? '')}
            </Text>
            <Text size="xs" mt={4}>
              Moves: {String(p.after?.moves ?? '')}
            </Text>
          </Box>
        )}

        {!isMerge && keys.length > 0 && (
          <Table withTableBorder withColumnBorders styles={{ td: { fontSize: 12, padding: '4px 8px' } }}>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>Field</Table.Th>
                <Table.Th>Before</Table.Th>
                <Table.Th>After</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {keys.map((k) => (
                <Table.Tr key={k}>
                  <Table.Td>{k}</Table.Td>
                  <Table.Td c="dimmed">{fmt(p.before?.[k])}</Table.Td>
                  <Table.Td fw={600}>{fmt(p.after?.[k])}</Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        )}

        {p.status === 'error' && p.error && (
          <Text size="xs" c="red">
            {p.error}
          </Text>
        )}

        {p.status === 'pending' && (
          <Group gap="xs" justify="flex-end">
            <Button size="xs" variant="default" leftSection={<IconX size={14} />} onClick={onReject}>
              Reject
            </Button>
            <Button size="xs" color="green" leftSection={<IconCheck size={14} />} onClick={onApprove}>
              Approve & apply
            </Button>
          </Group>
        )}
      </Stack>
    </Card>
  );
}

export function AssistantView() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [proposals, setProposals] = useState<TrackedProposal[]>([]);
  const [input, setInput] = useState('');
  const [busy, setBusy] = useState(false);
  const viewport = useRef<HTMLDivElement>(null);

  const scrollDown = () => requestAnimationFrame(() => viewport.current?.scrollTo({ top: viewport.current.scrollHeight }));

  async function send(text: string) {
    const content = text.trim();
    if (!content || busy) return;
    const next: ChatMessage[] = [...messages, { role: 'user', content }];
    setMessages(next);
    setInput('');
    setBusy(true);
    scrollDown();
    try {
      const { reply, proposals: newProps } = await api.adminChat(next);
      setMessages([...next, { role: 'assistant', content: reply }]);
      if (newProps.length) setProposals((cur) => [...cur, ...newProps.map((p) => ({ ...p, status: 'pending' as Status }))]);
    } catch (e) {
      setMessages([...next, { role: 'assistant', content: `⚠️ ${String(e)}` }]);
    } finally {
      setBusy(false);
      scrollDown();
    }
  }

  async function approve(p: TrackedProposal) {
    setProposals((cur) => cur.map((x) => (x.id === p.id ? { ...x, status: 'pending' } : x)));
    try {
      const { summary } = await api.applyCorrection(p.proposal);
      setProposals((cur) => cur.map((x) => (x.id === p.id ? { ...x, status: 'applied' } : x)));
      notifySuccess('Applied', `${summary} · ${p.partLabel}`);
    } catch (e) {
      setProposals((cur) => cur.map((x) => (x.id === p.id ? { ...x, status: 'error', error: String(e) } : x)));
      notifyError('Could not apply', String(e));
    }
  }

  function reject(p: TrackedProposal) {
    setProposals((cur) => cur.map((x) => (x.id === p.id ? { ...x, status: 'rejected' } : x)));
  }

  const pending = proposals.filter((p) => p.status === 'pending').length;

  return (
    <Group align="flex-start" gap="md" wrap="nowrap" style={{ height: 'calc(100vh - 160px)' }}>
      {/* Chat column */}
      <Stack gap="sm" style={{ flex: 1, minWidth: 0, height: '100%' }}>
        <ScrollArea style={{ flex: 1 }} viewportRef={viewport}>
          <Stack gap="sm" p="xs">
            {messages.length === 0 && (
              <Stack gap="sm" align="center" py="xl">
                <ThemeIcon size={48} radius="xl" variant="light">
                  <IconSparkles size={26} />
                </ThemeIcon>
                <Text fw={600}>Catalog-correction assistant</Text>
                <Text size="sm" c="dimmed" ta="center" maw={420}>
                  Ask me to normalize names, add aliases, or fix part numbers. I draft proposals — nothing changes until
                  you approve.
                </Text>
                <Stack gap={6} mt="sm">
                  {SUGGESTIONS.map((s) => (
                    <Button key={s} variant="light" size="xs" onClick={() => send(s)}>
                      {s}
                    </Button>
                  ))}
                </Stack>
              </Stack>
            )}
            {messages.map((m, i) => (
              <Group key={i} justify={m.role === 'user' ? 'flex-end' : 'flex-start'} align="flex-start" wrap="nowrap">
                {m.role === 'assistant' && (
                  <ThemeIcon size="sm" radius="xl" variant="light" mt={4}>
                    <IconRobot size={14} />
                  </ThemeIcon>
                )}
                <Paper
                  withBorder
                  radius="md"
                  px="sm"
                  py={6}
                  bg={m.role === 'user' ? 'var(--mantine-primary-color-light)' : undefined}
                  maw="80%"
                >
                  {m.role === 'assistant' ? (
                    <Markdown>{m.content}</Markdown>
                  ) : (
                    <Text size="sm" style={{ whiteSpace: 'pre-wrap' }}>
                      {m.content}
                    </Text>
                  )}
                </Paper>
              </Group>
            ))}
            {busy && (
              <Text size="xs" c="dimmed">
                Thinking…
              </Text>
            )}
          </Stack>
        </ScrollArea>
        <Group gap="xs" align="flex-end">
          <Textarea
            style={{ flex: 1 }}
            placeholder="Ask the assistant to correct catalog data…"
            autosize
            minRows={1}
            maxRows={4}
            value={input}
            onChange={(e) => setInput(e.currentTarget.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                void send(input);
              }
            }}
          />
          <ActionIcon size={36} variant="filled" aria-label="Send" loading={busy} onClick={() => send(input)}>
            <IconSend size={18} />
          </ActionIcon>
        </Group>
      </Stack>

      {/* Proposals column */}
      <Stack gap="sm" style={{ width: 420, height: '100%' }}>
        <Group gap="xs">
          <Title order={5}>Proposals</Title>
          {pending > 0 && (
            <Badge size="sm" variant="filled">
              {pending} pending
            </Badge>
          )}
        </Group>
        <ScrollArea style={{ flex: 1 }}>
          <Stack gap="sm" pr="xs">
            {proposals.length === 0 ? (
              <Text size="sm" c="dimmed">
                Proposals from the assistant appear here. Review the before → after, then approve to apply.
              </Text>
            ) : (
              proposals
                .slice()
                .reverse()
                .map((p) => <ProposalCard key={p.id} p={p} onApprove={() => approve(p)} onReject={() => reject(p)} />)
            )}
          </Stack>
        </ScrollArea>
      </Stack>
    </Group>
  );
}

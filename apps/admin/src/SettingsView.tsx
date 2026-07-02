import { useEffect, useState } from 'react';
import {
  Badge,
  Button,
  Card,
  Group,
  PasswordInput,
  Select,
  Stack,
  Text,
  TextInput,
  Title,
} from '@mantine/core';
import { IconDeviceFloppy, IconPlugConnected, IconSparkles } from '@tabler/icons-react';
import { api, getToken, setToken } from './api';
import { notifyError, notifySuccess } from './notify';
import type { AiSettings } from './types';

const PROVIDER_LABELS: Record<string, string> = {
  auto: 'Auto (by available key)',
  anthropic: 'Anthropic (Claude)',
  deepseek: 'DeepSeek',
  stub: 'Stub (no key, canned answers)',
};

function AiProviderCard() {
  const [ai, setAi] = useState<AiSettings | null>(null);
  const [loadErr, setLoadErr] = useState('');
  const [saving, setSaving] = useState(false);

  async function load() {
    setLoadErr('');
    try {
      setAi(await api.getAiSettings());
    } catch (e) {
      setLoadErr(String(e));
    }
  }

  useEffect(() => {
    void load();
  }, []);

  async function save() {
    if (!ai) return;
    setSaving(true);
    try {
      const next = await api.saveAiSettings({
        chatProvider: ai.chatProvider,
        chatModel: ai.chatModel,
        anthropicKey: ai.anthropicKey,
        deepseekKey: ai.deepseekKey,
      });
      setAi(next);
      notifySuccess('AI settings saved', 'Takes effect immediately — no deploy needed.');
    } catch (e) {
      notifyError('Could not save AI settings', String(e));
    } finally {
      setSaving(false);
    }
  }

  return (
    <Card withBorder maw={560}>
      <Stack>
        <Group gap="xs">
          <IconSparkles size={18} />
          <Title order={5}>AI provider</Title>
        </Group>

        {loadErr ? (
          <Text size="sm" c="dimmed">
            Could not load AI settings — save a valid admin token above first. ({loadErr})
          </Text>
        ) : !ai ? (
          <Text size="sm" c="dimmed">
            Loading…
          </Text>
        ) : (
          <>
            <Group gap="xs">
              <Badge variant="light" color={ai.activeChatProvider ? 'green' : 'red'}>
                chat: {ai.activeChatProvider ?? 'not configured'}
              </Badge>
              <Badge variant="light" color={ai.visionConfigured ? 'green' : 'red'}>
                extraction: {ai.visionConfigured ? 'configured (Anthropic)' : 'needs Anthropic key'}
              </Badge>
            </Group>
            <Select
              label="Chat provider (clerk assistant)"
              data={Object.entries(PROVIDER_LABELS).map(([value, label]) => ({ value, label }))}
              value={ai.chatProvider in PROVIDER_LABELS ? ai.chatProvider : 'auto'}
              onChange={(v) => setAi({ ...ai, chatProvider: v ?? 'auto' })}
              allowDeselect={false}
            />
            <PasswordInput
              label="Anthropic API key"
              description="Used for catalog extraction, and for chat when provider is Anthropic/auto. Empty = fall back to the server secret."
              value={ai.anthropicKey}
              onChange={(e) => setAi({ ...ai, anthropicKey: e.currentTarget.value })}
            />
            <PasswordInput
              label="DeepSeek API key"
              description="Used for chat when provider is DeepSeek/auto."
              value={ai.deepseekKey}
              onChange={(e) => setAi({ ...ai, deepseekKey: e.currentTarget.value })}
            />
            <TextInput
              label="Chat model override"
              description="Optional — leave empty for the provider default."
              placeholder="e.g. deepseek-chat"
              value={ai.chatModel}
              onChange={(e) => setAi({ ...ai, chatModel: e.currentTarget.value })}
            />
            <Group>
              <Button leftSection={<IconDeviceFloppy size={16} />} onClick={save} loading={saving}>
                Save AI settings
              </Button>
            </Group>
          </>
        )}
      </Stack>
    </Card>
  );
}

export function SettingsView() {
  const [token, setTok] = useState(getToken());
  const [testing, setTesting] = useState(false);

  async function testConnection() {
    setTesting(true);
    try {
      await api.checkAuth();
      notifySuccess('Connection OK', 'The admin token is valid.');
    } catch (e) {
      notifyError('Connection failed', String(e));
    } finally {
      setTesting(false);
    }
  }

  return (
    <Stack>
      <Card withBorder maw={560}>
        <Stack>
          <Title order={5}>Admin token</Title>
          <PasswordInput
            label="Bearer token for write operations"
            description="Dev default: dev-admin-token"
            value={token}
            onChange={(e) => setTok(e.currentTarget.value)}
          />
          <Group>
            <Button
              leftSection={<IconDeviceFloppy size={16} />}
              onClick={() => {
                setToken(token);
                notifySuccess('Token saved');
              }}
            >
              Save token
            </Button>
            <Button
              variant="default"
              leftSection={<IconPlugConnected size={16} />}
              loading={testing}
              onClick={() => {
                setToken(token); // test what's in the field, not the stale stored value
                void testConnection();
              }}
            >
              Test connection
            </Button>
          </Group>
        </Stack>
      </Card>

      <AiProviderCard />
    </Stack>
  );
}

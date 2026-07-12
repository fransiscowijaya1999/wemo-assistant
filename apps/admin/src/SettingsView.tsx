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
import { IconDeviceFloppy, IconPlugConnected, IconSparkles, IconDownload, IconUpload } from '@tabler/icons-react';
import { api, getToken, setToken } from './api';
import { notifyError, notifySuccess } from './notify';
import type { AiSettings } from './types';

function BackupRestoreCard() {
  const [restoring, setRestoring] = useState(false);
  const [downloading, setDownloading] = useState(false);

  async function handleDownload() {
    setDownloading(true);
    try {
      const res = await fetch('/api/admin/backup', {
        headers: { Authorization: `Bearer ${getToken()}` },
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text || res.statusText);
      }
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      // Get filename from content-disposition if possible, otherwise generate one
      const cd = res.headers.get('Content-Disposition');
      let filename = `wemo-backup-${new Date().toISOString().slice(0, 10)}.json`;
      if (cd && cd.includes('filename=')) {
        filename = cd.split('filename=')[1].replace(/["']/g, '');
      }
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      notifySuccess('Backup downloaded');
    } catch (e) {
      notifyError('Backup failed', String(e));
    } finally {
      setDownloading(false);
    }
  }

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    
    // reset input so the same file can be selected again
    e.target.value = '';

    if (!window.confirm(`Restore from ${file.name}? This will overwrite existing matching records.`)) {
      return;
    }

    setRestoring(true);
    const reader = new FileReader();
    reader.onload = async (ev) => {
      try {
        const text = ev.target?.result as string;
        const archive = JSON.parse(text);
        
        const res = await fetch('/api/admin/restore', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${getToken()}`,
          },
          body: JSON.stringify(archive),
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data?.error || res.statusText);
        
        notifySuccess('Restore complete', `Images: ${data.imageCount}`);
      } catch (err) {
        notifyError('Restore failed', String(err));
      } finally {
        setRestoring(false);
      }
    };
    reader.onerror = () => {
      notifyError('Restore failed', 'Could not read file');
      setRestoring(false);
    };
    reader.readAsText(file);
  }

  return (
    <Card withBorder maw={560}>
      <Stack>
        <Group gap="xs">
          <IconDeviceFloppy size={18} />
          <Title order={5}>Backup / Restore</Title>
        </Group>
        <Text size="sm" c="dimmed">
          Snapshot the whole catalog (data + images) and replay it here. 
          Restore is idempotent: it safely upserts existing records.
        </Text>
        <Group>
          <Button 
            leftSection={<IconDownload size={16} />} 
            onClick={handleDownload} 
            loading={downloading}
          >
            Download backup
          </Button>
          <Button
            variant="default"
            leftSection={<IconUpload size={16} />}
            loading={restoring}
            onClick={() => document.getElementById('restore-upload')?.click()}
          >
            Restore backup
          </Button>
          <input 
            type="file" 
            id="restore-upload" 
            accept=".json,application/json" 
            style={{ display: 'none' }}
            onChange={handleFileChange} 
          />
        </Group>
      </Stack>
    </Card>
  );
}

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
        visionModel: ai.visionModel,
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
                extraction: {ai.visionConfigured ? ai.visionModelEffective : 'needs Anthropic key'}
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
            <TextInput
              label="Extraction model (Anthropic only)"
              description="Catalog-page extraction always runs on Anthropic — DeepSeek's API cannot read images. Must be a claude-* model; empty = default."
              placeholder="default: claude-opus-4-8"
              value={ai.visionModel}
              onChange={(e) => setAi({ ...ai, visionModel: e.currentTarget.value })}
              error={
                ai.visionModel && !ai.visionModel.toLowerCase().startsWith('claude')
                  ? 'Not an Anthropic model — extraction would fail'
                  : undefined
              }
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
      <BackupRestoreCard />
    </Stack>
  );
}

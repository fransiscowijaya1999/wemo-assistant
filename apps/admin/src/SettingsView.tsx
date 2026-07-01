import { useState } from 'react';
import { Button, Group, Stack, Text, TextInput } from '@mantine/core';
import { getToken, setToken } from './api';

export function SettingsView() {
  const [token, setTok] = useState(getToken());
  const [saved, setSaved] = useState(false);
  return (
    <Stack maw={520}>
      <TextInput
        label="Admin token"
        description="Bearer token for write operations (dev: dev-admin-token)"
        value={token}
        onChange={(e) => {
          setTok(e.currentTarget.value);
          setSaved(false);
        }}
      />
      <Group>
        <Button
          onClick={() => {
            setToken(token);
            setSaved(true);
          }}
        >
          Save token
        </Button>
        {saved && <Text c="green">Saved.</Text>}
      </Group>
    </Stack>
  );
}

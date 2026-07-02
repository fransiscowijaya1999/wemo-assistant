import { notifications } from '@mantine/notifications';
import { IconCheck, IconX } from '@tabler/icons-react';

// Consistent transient feedback across views; inline Alerts stay only where the
// message must sit next to its context (e.g. an extraction error above the table).

export function notifySuccess(title: string, message?: string) {
  notifications.show({ title, message, color: 'green', icon: <IconCheck size={16} /> });
}

export function notifyError(title: string, message?: string) {
  notifications.show({ title, message, color: 'red', icon: <IconX size={16} /> });
}

import ReactMarkdown from 'react-markdown';
import { Typography } from '@mantine/core';

/// Renders assistant/markdown text with sensible in-bubble spacing. The model
/// emits markdown (bold, `code`, bullet/numbered lists) — without this it shows
/// as literal `**` / `-` characters.
export function Markdown({ children }: { children: string }) {
  return (
    <Typography
      // `.wemo-md` (styles.css) tightens the default block margins so a single
      // paragraph reads like plain text and lists don't blow out the bubble.
      style={{ fontSize: 'var(--mantine-font-size-sm)' }}
      className="wemo-md"
    >
      <ReactMarkdown>{children}</ReactMarkdown>
    </Typography>
  );
}

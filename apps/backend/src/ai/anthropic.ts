import Anthropic from '@anthropic-ai/sdk';
import { zodOutputFormat } from '@anthropic-ai/sdk/helpers/zod';
import { extractedPage } from './types';
import type { ExtractCatalogPageInput, VisionExtractionProvider } from './provider';

const SYSTEM = `You extract structured data from Honda Indonesia motorcycle spare-parts catalog
("Katalog Suku Cadang") assembly pages. A page has an assembly code + name, an exploded diagram with
numbered balloons, a parts table, and often a Service item / F.R.T. table.

Rules:
- Transcribe verbatim. Never invent or "correct" part numbers, descriptions, or quantities.
- Descriptions are English and comma-inverted (e.g. "GASKET, CYLINDER HEAD"). Keep them exactly.
- Parts table columns are: No. (ref/balloon number) | Part Number | Description | QTY | Notes.
- A single ref number may list MULTIPLE part numbers (interchangeable/alternate parts) — capture
  every one under that item's partNumbers. If a brand is shown (e.g. NGK, Denso) or a spec in
  parentheses, record it in brand/note.
- A part number printed under a description usually means supersession — record it with a note.
- Also extract the Service item / F.R.T. table (name + labor hours) if present.
- If a field is not present, omit it. Do not guess.`;

export function createAnthropicVisionProvider(
  apiKey: string,
  model = 'claude-opus-4-8',
): VisionExtractionProvider {
  const client = new Anthropic({ apiKey });
  return {
    async extractCatalogPage({ imageBase64, mediaType }: ExtractCatalogPageInput) {
      const res = await client.messages.parse({
        model,
        max_tokens: 16000,
        thinking: { type: 'adaptive' },
        system: SYSTEM,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'image', source: { type: 'base64', media_type: mediaType, data: imageBase64 } },
              {
                type: 'text',
                text: 'Extract the assembly header, the full parts table, and the service/FRT table from this catalog page.',
              },
            ],
          },
        ],
        output_config: { format: zodOutputFormat(extractedPage) },
      });

      if (!res.parsed_output) {
        throw new Error(`extraction returned no structured output (stop_reason=${res.stop_reason})`);
      }
      return res.parsed_output;
    },
  };
}

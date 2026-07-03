import Anthropic from '@anthropic-ai/sdk';
import { zodOutputFormat } from '@anthropic-ai/sdk/helpers/zod';
import type { z } from 'zod';
import { extractedColorPage, extractedPage } from './types';
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
- Return "diagram": the bounding box {x, y, width, height} of the exploded-diagram region, each value
  normalized 0..1 relative to the full image (x,y = top-left corner). Omit it only if the whole image
  is the diagram.
- For each item, return "dots": approximate {x, y} positions (normalized 0..1 to the full image) of
  that ref's balloon number(s) on the diagram - one entry per balloon (a ref may appear multiple
  times). Use an empty array if you cannot locate it. These are best-effort estimates a human will
  fine-tune.
- 2024-edition pages may add a "No. Seri" (frame serial range) column and split the quantity into
  one "Jumlah" column PER VARIANT (column headers like STD, ABS). If present:
  - Return "variantColumns": the variant column header names, verbatim and in printed order.
  - On each part-number row, return "variantQtys": one { variant, qty } per NON-EMPTY variant cell
    (skip blank or "-" cells — blank means the part does not apply to that variant).
  - Return "serialFrom"/"serialTo" from the No. Seri cell, digits verbatim: a range printed as
    "up to / s/d N" means serialTo=N; "from N" or "N onward" means serialFrom=N; "A - B" means both.
    A ref listing several part numbers with different serial ranges is a serial split — keep each
    number's own range on its own entry.
- On pages WITHOUT these columns, omit variantColumns, variantQtys, serialFrom and serialTo entirely.
- If a field is not present, omit it. Do not guess text you cannot read.`;

const COLOR_SYSTEM = `You extract data from a Honda Indonesia parts-catalog COLOR INDEX page, which
maps colored parts to color-specific part-number suffixes.

Columns: No. | colored part name | base part number ("No. part dasar") | one column per body color
(the column header is a color code like NH-436M plus a color name; each cell is a 2-character suffix
code like ZE, or is blank / "-") | applicable model range | "No. blok" (assembly/block code, e.g.
F-13) | "No. Ref" (balloon number in that block).

Rules:
- Transcribe verbatim. Never invent suffixes, numbers, or names.
- colors: list each color column's code and name exactly as shown in the header.
- For each row: capture partName, baseNumber, blockCode ("No. blok") and refNo ("No. Ref") if
  present, and one variant per NON-EMPTY color cell as { colorCode (that column's color code),
  suffix (the cell value) }.
- Skip empty cells and cells shown as "-".
- If a field is not present, omit it. Do not guess.`;

export const DEFAULT_VISION_MODEL = 'claude-opus-4-8';

// A page extraction can legitimately generate for several minutes (adaptive thinking
// on a dense or unusual page). A non-streaming call only receives HTTP headers once
// generation FINISHES server-side, so long pages died on the request timeout no matter
// its value. Streaming gets headers immediately — the SDK clears its timeout at that
// point — so the timeout below only guards connection/first-byte, and generation can
// run as long as it needs (bounded by max_tokens).
async function streamExtraction<T>(
  client: Anthropic,
  params: Anthropic.MessageStreamParams,
  schema: z.ZodType<T>,
): Promise<T> {
  const msg = await client.messages.stream(params).finalMessage();
  if (msg.stop_reason === 'max_tokens') {
    throw new Error('extraction hit max_tokens before finishing — page too dense for one call');
  }
  const text = msg.content
    .filter((b): b is Anthropic.TextBlock => b.type === 'text')
    .map((b) => b.text)
    .join('');
  if (!text) {
    throw new Error(`extraction returned no structured output (stop_reason=${msg.stop_reason})`);
  }
  return schema.parse(JSON.parse(text));
}

export function createAnthropicVisionProvider(
  apiKey: string,
  model = DEFAULT_VISION_MODEL,
): VisionExtractionProvider {
  const client = new Anthropic({ apiKey, timeout: 120_000, maxRetries: 1 });
  return {
    async extractCatalogPage({ imageBase64, mediaType }: ExtractCatalogPageInput) {
      return streamExtraction(
        client,
        {
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
                  text: 'Extract the assembly header, the full parts table, the service/FRT table, the diagram bounding box, and each ref\'s balloon coordinates from this catalog page.',
                },
              ],
            },
          ],
          output_config: { format: zodOutputFormat(extractedPage) },
        },
        extractedPage,
      );
    },

    async extractColorPage({ imageBase64, mediaType }: ExtractCatalogPageInput) {
      return streamExtraction(
        client,
        {
          model,
          max_tokens: 16000,
          thinking: { type: 'adaptive' },
          system: COLOR_SYSTEM,
          messages: [
            {
              role: 'user',
              content: [
                { type: 'image', source: { type: 'base64', media_type: mediaType, data: imageBase64 } },
                {
                  type: 'text',
                  text: 'Extract the color legend and every colored-part row from this color-index page.',
                },
              ],
            },
          ],
          output_config: { format: zodOutputFormat(extractedColorPage) },
        },
        extractedColorPage,
      );
    },
  };
}

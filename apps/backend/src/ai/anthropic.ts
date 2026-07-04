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
- ALWAYS return "diagram": the bounding box {x, y, width, height} of the exploded-diagram region,
  each value normalized 0..1 relative to the full image (x,y = top-left corner). The box must contain
  the exploded drawing and its balloon numbers but EXCLUDE the parts table, the page header bar and
  outer margins. Only if the drawing genuinely fills the entire page, return {x:0,y:0,width:1,height:1}.
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

// Adaptive thinking exists on the 4.6+ Opus/Sonnet/Fable models; Haiku 4.5 (and
// older pre-4.6 models) reject `thinking: {type: 'adaptive'}` with a 400, so for
// those we omit the thinking param entirely (extraction is perception-heavy, not
// reasoning-heavy — dots/bbox are best-effort and human-tuned anyway).
function thinkingFor(model: string): { thinking: { type: 'adaptive' } } | Record<string, never> {
  return /haiku|-4-5\b|-4-5-/.test(model) ? {} : { thinking: { type: 'adaptive' } };
}

// A page extraction can legitimately generate for several minutes (adaptive thinking
// on a dense or unusual page). A non-streaming call only receives HTTP headers once
// generation FINISHES server-side, so long pages died on the request timeout no matter
// its value. Streaming gets headers immediately — the SDK clears its timeout at that
// point — so the timeout below only guards connection/first-byte, and generation can
// run as long as it needs (bounded by max_tokens).
// No stream event for this long = the connection is dead or the server hung; abort
// and retry rather than waiting on finalMessage() forever. Generous because adaptive
// thinking can pause visible output, but ping/delta events still flow while alive.
const STALL_MS = 90_000;
const MAX_ATTEMPTS = 3;

class ExtractionStallError extends Error {
  constructor(seconds: number) {
    super(`extraction stream stalled — no data from the API for ${seconds}s`);
  }
}

// Mid-stream failures are NOT retried by the SDK (its maxRetries only covers errors
// before first byte), so we retry here: connection drops, stalls, and retryable API
// statuses (rate limit / overloaded / server errors). Bad requests, auth failures,
// max_tokens and schema mismatches are deterministic — fail fast on those.
function isTransient(err: unknown): boolean {
  if (err instanceof ExtractionStallError || err instanceof Anthropic.APIConnectionError) return true;
  if (err instanceof Anthropic.APIError && typeof err.status === 'number') {
    return err.status === 408 || err.status === 429 || err.status >= 500;
  }
  return false;
}

async function streamExtraction<T>(
  client: Anthropic,
  params: Anthropic.MessageStreamParams,
  schema: z.ZodType<T>,
): Promise<T> {
  for (let attempt = 1; ; attempt++) {
    try {
      return await streamExtractionOnce(client, params, schema, attempt);
    } catch (err) {
      if (attempt >= MAX_ATTEMPTS || !isTransient(err)) throw err;
      const delayMs = 2_000 * attempt;
      console.log(`[extract] attempt ${attempt} failed (${err instanceof Error ? err.message : err}), retrying in ${delayMs / 1000}s`);
      await new Promise((r) => setTimeout(r, delayMs));
    }
  }
}

async function streamExtractionOnce<T>(
  client: Anthropic,
  params: Anthropic.MessageStreamParams,
  schema: z.ZodType<T>,
  attempt: number,
): Promise<T> {
  const started = Date.now();
  const stream = client.messages.stream(params);
  let events = 0;
  let stalled = false;
  let watchdog = setTimeout(onStall, STALL_MS);
  function onStall() {
    stalled = true;
    stream.abort();
  }
  stream.on('streamEvent', () => {
    events += 1;
    clearTimeout(watchdog);
    watchdog = setTimeout(onStall, STALL_MS);
    if (events % 500 === 0) {
      console.log(`[extract] streaming… ${events} events, ${Math.round((Date.now() - started) / 1000)}s`);
    }
  });
  let msg: Anthropic.Message;
  try {
    msg = await stream.finalMessage();
  } catch (err) {
    if (stalled) throw new ExtractionStallError(Math.round(STALL_MS / 1000));
    throw err;
  } finally {
    clearTimeout(watchdog);
  }
  console.log(
    `[extract] finished in ${Math.round((Date.now() - started) / 1000)}s ` +
      `(attempt=${attempt}, stop=${msg.stop_reason}, out=${msg.usage.output_tokens} tokens)`,
  );
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
  let json: unknown;
  try {
    json = JSON.parse(text);
  } catch {
    throw new Error(`extraction output is not valid JSON (stop_reason=${msg.stop_reason}, ${text.length} chars)`);
  }
  const parsed = schema.safeParse(json);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .slice(0, 3)
      .map((i) => `${i.path.join('.')}: ${i.message}`)
      .join('; ');
    throw new Error(`extraction output failed schema validation — ${issues}`);
  }
  return parsed.data;
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
          ...thinkingFor(model),
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
          ...thinkingFor(model),
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

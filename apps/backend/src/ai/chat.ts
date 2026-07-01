// Model-agnostic chat seam for the CLERK-facing assistant.
//
// AUTHORIZATION INVARIANT (load-bearing): this path is strictly READ-ONLY. The
// assistant may look up / summarize / explain catalog data via the provided
// tools, but it has NO mutating tools and the route performs no writes. See
// CLAUDE.md. Any future tool added here must be a pure read.

export type ChatRole = 'user' | 'assistant';

export interface ChatMessage {
  role: ChatRole;
  content: string;
}

/** A catalog part surfaced by a tool during a turn, for the UI to link to. */
export interface Citation {
  partId: string;
  name: string;
  primaryNumber: string | null;
}

/** Anthropic-style tool definition (JSON-schema input). Provider-agnostic. */
export interface ChatToolDef {
  name: string;
  description: string;
  input_schema: Record<string, unknown>;
}

/** Executes a named tool with the model-supplied input; returns JSON-able data. */
export type ToolExecutor = (name: string, input: Record<string, unknown>) => Promise<unknown>;

export interface ChatRequest {
  system: string;
  messages: ChatMessage[];
  tools: ChatToolDef[];
  executeTool: ToolExecutor;
}

/** A chat model that can call read-only tools and return a final text answer. */
export interface ChatProvider {
  chat(req: ChatRequest): Promise<string>;
}

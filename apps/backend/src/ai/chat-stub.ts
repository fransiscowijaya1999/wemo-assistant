import type { ChatProvider, ChatRequest } from './chat';

/**
 * Keyless stub for local dev/testing (enabled with AI_CHAT=stub). It still
 * exercises the real read-only `search_parts` tool against the DB, so the full
 * endpoint → tools → citations pipeline is verifiable without an API key. The
 * real provider is a drop-in replacement.
 */
export function createStubChatProvider(): ChatProvider {
  return {
    async chat({ messages, executeTool }: ChatRequest): Promise<string> {
      const lastUser = [...messages].reverse().find((m) => m.role === 'user');
      const q = (lastUser?.content ?? '').trim();

      const res = (await executeTool('search_parts', { query: q })) as {
        results?: { name: string; primaryNumber: string | null }[];
      };
      const results = res.results ?? [];

      if (!results.length) {
        return `[stub] No catalog parts matched “${q}”. Try a part number or a different term.`;
      }
      const lines = results
        .slice(0, 5)
        .map((r) => `• ${r.name}${r.primaryNumber ? ` — ${r.primaryNumber}` : ''}`)
        .join('\n');
      return (
        `[stub] Found ${results.length} part(s) matching “${q}”:\n${lines}\n\n` +
        `(Stub reply — set ANTHROPIC_API_KEY to enable the real assistant.)`
      );
    },
  };
}

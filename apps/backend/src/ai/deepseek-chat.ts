import type { ChatProvider, ChatRequest } from './chat';

const MAX_TOOL_ROUNDS = 8;
const BASE_URL = 'https://api.deepseek.com';

// DeepSeek is OpenAI-compatible. `deepseek-chat` supports function/tool calling
// (note: `deepseek-reasoner` does NOT). Fetch-based, so no extra dependency runs
// in the Worker.

interface OAToolCall {
  id: string;
  type: 'function';
  function: { name: string; arguments: string };
}

interface OAAssistantMessage {
  role: 'assistant';
  content: string | null;
  tool_calls?: OAToolCall[];
}

interface OAChatResponse {
  choices?: { message?: OAAssistantMessage }[];
}

type OAMessage =
  | { role: 'system' | 'user' | 'assistant'; content: string }
  | OAAssistantMessage
  | { role: 'tool'; tool_call_id: string; content: string };

/**
 * DeepSeek-backed chat with read-only tool use, via the OpenAI-compatible
 * `/chat/completions` endpoint. Same read-only tools as the Claude provider.
 */
export function createDeepSeekChatProvider(apiKey: string, model = 'deepseek-chat'): ChatProvider {
  return {
    async chat({ system, messages, tools, executeTool }: ChatRequest): Promise<string> {
      const convo: OAMessage[] = [
        { role: 'system', content: system },
        ...messages.map((m) => ({ role: m.role, content: m.content })),
      ];

      const oaTools = tools.map((t) => ({
        type: 'function' as const,
        function: { name: t.name, description: t.description, parameters: t.input_schema },
      }));

      // One /chat/completions call. `withTools=false` forces a plain text answer.
      const call = async (withTools: boolean): Promise<OAAssistantMessage> => {
        const res = await fetch(`${BASE_URL}/chat/completions`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({
            model,
            messages: convo,
            max_tokens: 1536,
            ...(withTools ? { tools: oaTools, tool_choice: 'auto' } : {}),
          }),
        });
        if (!res.ok) {
          const detail = await res.text().catch(() => '');
          throw new Error(`DeepSeek HTTP ${res.status}: ${detail.slice(0, 300)}`);
        }
        const data = (await res.json()) as OAChatResponse;
        const msg = data.choices?.[0]?.message;
        if (!msg) throw new Error('DeepSeek returned no message');
        return msg;
      };

      for (let round = 0; round < MAX_TOOL_ROUNDS; round++) {
        const msg = await call(true);
        convo.push(msg);

        const toolCalls = msg.tool_calls ?? [];
        if (!toolCalls.length) return (msg.content ?? '').trim() || '(no answer)';

        for (const tc of toolCalls) {
          let input: Record<string, unknown> = {};
          try {
            input = JSON.parse(tc.function.arguments || '{}') as Record<string, unknown>;
          } catch {
            input = {};
          }
          let result: unknown;
          try {
            result = await executeTool(tc.function.name, input);
          } catch (e) {
            result = { error: String(e) };
          }
          convo.push({ role: 'tool', tool_call_id: tc.id, content: JSON.stringify(result) });
        }
      }

      // Out of tool rounds — force a final answer from what was already gathered.
      const finalMsg = await call(false);
      return (finalMsg.content ?? '').trim() || 'Sorry, I could not complete that lookup — please try rephrasing.';
    },
  };
}

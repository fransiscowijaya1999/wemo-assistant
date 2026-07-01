import Anthropic from '@anthropic-ai/sdk';
import type { ChatProvider, ChatRequest } from './chat';

const MAX_TOOL_ROUNDS = 8;

/**
 * Claude-backed chat with read-only tool use. Runs the standard tool loop:
 * call the model, execute any tool_use blocks (which only read the catalog),
 * feed results back, until the model produces a final text answer. If it runs
 * out of tool rounds, a final tool-free call forces an answer from what was
 * already gathered.
 */
export function createAnthropicChatProvider(apiKey: string, model = 'claude-opus-4-8'): ChatProvider {
  const client = new Anthropic({ apiKey });

  return {
    async chat({ system, messages, tools, executeTool }: ChatRequest): Promise<string> {
      const convo: Anthropic.MessageParam[] = messages.map((m) => ({ role: m.role, content: m.content }));

      const toolDefs: Anthropic.Tool[] = tools.map((t) => ({
        name: t.name,
        description: t.description,
        input_schema: t.input_schema as Anthropic.Tool.InputSchema,
      }));

      const call = (withTools: boolean) =>
        client.messages.create({
          model,
          max_tokens: 1536,
          system,
          ...(withTools ? { tools: toolDefs } : {}),
          messages: convo,
        });

      const textOf = (blocks: Anthropic.ContentBlock[]) =>
        blocks
          .filter((b): b is Anthropic.TextBlock => b.type === 'text')
          .map((b) => b.text)
          .join('\n')
          .trim();

      for (let round = 0; round < MAX_TOOL_ROUNDS; round++) {
        const res = await call(true);
        convo.push({ role: 'assistant', content: res.content });

        const toolUses = res.content.filter((b): b is Anthropic.ToolUseBlock => b.type === 'tool_use');
        if (res.stop_reason !== 'tool_use' || !toolUses.length) {
          return textOf(res.content) || '(no answer)';
        }

        const toolResults: Anthropic.ToolResultBlockParam[] = [];
        for (const tu of toolUses) {
          let result: unknown;
          try {
            result = await executeTool(tu.name, (tu.input ?? {}) as Record<string, unknown>);
          } catch (e) {
            result = { error: String(e) };
          }
          toolResults.push({ type: 'tool_result', tool_use_id: tu.id, content: JSON.stringify(result) });
        }
        convo.push({ role: 'user', content: toolResults });
      }

      // Out of tool rounds — force a final answer from what was already gathered.
      const finalRes = await call(false);
      return textOf(finalRes.content) || 'Sorry, I could not complete that lookup — please try rephrasing.';
    },
  };
}

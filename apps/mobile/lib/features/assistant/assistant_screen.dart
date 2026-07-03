import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/connectivity/connectivity_controller.dart';
import '../search/part_detail_screen.dart';
import 'assistant_controller.dart';
import 'models.dart';

/// Read-only, online-only AI assistant: the clerk describes a vague/broken part
/// and gets an answer grounded in the catalog. Offline, it points back to
/// Search/Browse. It can never modify data.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send([String? text]) {
    final t = (text ?? _input.text).trim();
    if (t.isEmpty) return;
    if (text == null) _input.clear();
    context.read<AssistantController>().send(t);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AssistantController>();
    final online = context.watch<ConnectivityController>().online;
    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        actions: [
          if (c.messages.isNotEmpty)
            IconButton(
              tooltip: 'Clear chat',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => context.read<AssistantController>().clear(),
            ),
        ],
      ),
      body: Column(
        children: [
          if (online == false)
            _OfflineBanner(onRetry: () => context.read<ConnectivityController>().probe()),
          Expanded(
            child: c.messages.isEmpty
                ? _EmptyState(onPrompt: _send)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: c.messages.length + (c.sending ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= c.messages.length) return const _ThinkingBubble();
                      return _MessageBubble(
                        message: c.messages[i],
                        onRetry: c.messages[i].isError && i == c.messages.length - 1
                            ? () => context.read<AssistantController>().retry()
                            : null,
                      );
                    },
                  ),
          ),
          _InputBar(
            controller: _input,
            enabled: online != false,
            sending: c.sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onRetry});
  final ChatMessage message;

  /// Set on the trailing error bubble: re-sends the failed request.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == ChatRole.user;
    final bg = message.isError
        ? theme.colorScheme.errorContainer
        : isUser
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest;
    final fg = message.isError
        ? theme.colorScheme.onErrorContainer
        : isUser
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(message.text, style: TextStyle(color: fg)),
            if (onRetry != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh, size: 18, color: fg),
                  label: Text('Retry', style: TextStyle(color: fg)),
                ),
              ),
            if (message.citations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final cit in message.citations)
                    ActionChip(
                      avatar: const Icon(Icons.open_in_new, size: 16),
                      label: Text(cit.primaryNumber == null ? cit.name : '${cit.name} · ${cit.primaryNumber}'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PartDetailScreen(partId: cit.partId)),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 10),
            Text(
              'Looking up the catalog…',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.sending,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool enabled; // false while the backend is unreachable
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const Key('assistantInput'),
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => sending ? null : onSend(),
                decoration: InputDecoration(
                  hintText: enabled
                      ? 'Describe the part, or paste a number…'
                      : 'Offline — assistant unavailable',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: (sending || !enabled) ? null : onSend,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 18, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Offline — the assistant needs a connection. Use Search / Browse meanwhile.',
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// First-open state: what the assistant is for, plus tappable example asks so
/// the clerk doesn't face a blank box.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPrompt});

  final void Function(String) onPrompt;

  static const _suggestions = [
    'paking kepala silinder BeAT',
    'Kampas rem depan PCX 160, nomornya berapa?',
    'Apakah 14100-K0J-901 sama dengan 14100-K0J-900?',
    'Customer bawa part patah, tidak ada nomornya — bagaimana carinya?',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Ask about a part', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Describe a broken or vague part, or paste any number. '
              'The assistant looks it up in the catalog — it never changes anything.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final s in _suggestions)
                  ActionChip(
                    avatar: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: Text(s),
                    onPressed: () => onPrompt(s),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

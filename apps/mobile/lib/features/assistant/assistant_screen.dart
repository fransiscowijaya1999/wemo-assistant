import 'package:flutter/material.dart';

/// Placeholder for the read-only, online-only AI assistant (next slice).
/// It will let the clerk describe a vague/broken part and get an AI-assisted
/// answer grounded in the catalog — look-up only, never any mutation.
class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.smart_toy_outlined, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('AI Assistant', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Describe a vague or broken part and get an answer grounded in the '
                'catalog. Online only — offline, use Search and Browse.\n\nArriving in the next update.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

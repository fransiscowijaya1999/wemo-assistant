import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/settings/app_settings.dart';
import '../../core/util/relative_time.dart';
import 'sync_controller.dart';

/// M1 debug/sync screen: set the backend URL, pull the catalog, and see
/// per-table row counts land in the local replica.
class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late final TextEditingController _urlController;
  late final TextEditingController _apiKeyController;
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppSettings>();
    _urlController = TextEditingController(text: settings.baseUrl);
    _apiKeyController = TextEditingController(text: settings.apiKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final settings = context.read<AppSettings>();
    await settings.setBaseUrl(_urlController.text);
    await settings.setApiKey(_apiKeyController.text);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Backend settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SyncController>();
    final syncing = controller.status == SyncStatus.syncing;
    final total = controller.tableCounts.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Wemo Clerk — Sync')),
      body: RefreshIndicator(
        onRefresh: () => context.read<SyncController>().refreshCounts(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Backend URL',
                helperText: 'Emulator → http://10.0.2.2:8787 reaches the PC',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save_outlined),
                  tooltip: 'Save settings',
                  onPressed: _saveSettings,
                ),
              ),
              onSubmitted: (_) => _saveSettings(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: !_showApiKey,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'API key',
                helperText: 'Clerk read key from the shop owner (stored on this phone only)',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_showApiKey ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      tooltip: _showApiKey ? 'Hide key' : 'Show key',
                      onPressed: () => setState(() => _showApiKey = !_showApiKey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save_outlined),
                      tooltip: 'Save settings',
                      onPressed: _saveSettings,
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => _saveSettings(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: syncing ? null : () => context.read<SyncController>().syncNow(),
              icon: syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.sync),
              label: Text(syncing ? 'Syncing…' : 'Sync now'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: syncing ? null : () => context.read<SyncController>().forceFullSync(),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Force full sync'),
            ),
            const SizedBox(height: 8),
            _StatusBanner(controller: controller),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Replica contents', style: Theme.of(context).textTheme.titleMedium),
                Text('$total rows', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            ...controller.tableCounts.entries.map(
              (e) => _CountTile(label: _pretty(e.key), count: e.value),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.controller});
  final SyncController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (IconData icon, Color color, String text) = switch (controller.status) {
      SyncStatus.idle => (
        Icons.info_outline,
        scheme.onSurfaceVariant,
        controller.lastSyncedAt == null
            ? 'Never synced. Set the URL and tap Sync now.'
            : 'Last synced ${relativeAgo(controller.lastSyncedAt!)}.',
      ),
      SyncStatus.syncing => (
        Icons.sync,
        scheme.primary,
        'Pulling… ${controller.pagesPulled} page(s), ${controller.rowsPulled} row(s).',
      ),
      SyncStatus.success => (
        Icons.check_circle_outline,
        Colors.green.shade700,
        'Synced ${controller.rowsPulled} row(s), ${controller.imagesFetched} image(s) '
            'across ${controller.pagesPulled} page(s). Last synced ${relativeAgo(controller.lastSyncedAt!)}.',
      ),
      SyncStatus.error => (Icons.error_outline, scheme.error, controller.errorMessage ?? 'Sync failed'),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: color))),
        ],
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final empty = count == 0;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        '$count',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: empty ? Theme.of(context).colorScheme.onSurfaceVariant : null,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

String _pretty(String camel) {
  final withSpaces = camel.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}');
  return withSpaces.isEmpty ? camel : withSpaces[0].toUpperCase() + withSpaces.substring(1);
}

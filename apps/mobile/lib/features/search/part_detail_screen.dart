import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../browse/diagram_screen.dart';
import 'data/lookup_repository.dart';
import 'models.dart';

class PartDetailScreen extends StatefulWidget {
  const PartDetailScreen({super.key, required this.partId});

  final String partId;

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  late final Future<PartDetail?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<LookupRepository>().partDetail(widget.partId);
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Copied $value')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Part')),
      body: FutureBuilder<PartDetail?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final part = snap.data;
          if (part == null) return const Center(child: Text('Part not found.'));
          return _content(context, part);
        },
      ),
    );
  }

  Widget _content(BuildContext context, PartDetail part) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(part.name, style: theme.textTheme.headlineSmall),
        if (part.category != null) ...[
          const SizedBox(height: 4),
          Text(part.category!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
        if (part.notes != null) ...[
          const SizedBox(height: 8),
          Text(part.notes!, style: theme.textTheme.bodyMedium),
        ],

        _SectionTitle('Part numbers', count: part.numbers.length),
        ...part.numbers.map((n) => _NumberTile(number: n, onTap: () => _copy(n.value))),

        if (part.colorVariants.isNotEmpty) ...[
          const _SectionTitle('Color variants'),
          ...part.colorVariants.map(
            (v) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.palette_outlined),
              title: Text(v.fullNumber ?? '${v.colorCode} (${v.suffixCode ?? '—'})'),
              subtitle: Text('${v.colorCode} · ${v.colorName}'),
              trailing: v.fullNumber == null ? null : const Icon(Icons.copy, size: 18),
              onTap: v.fullNumber == null ? null : () => _copy(v.fullNumber!),
            ),
          ),
        ],

        if (part.aliases.isNotEmpty) ...[
          const _SectionTitle('Also known as'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [for (final a in part.aliases) Chip(label: Text(a))],
          ),
        ],

        if (part.placements.isNotEmpty) ...[
          _SectionTitle('Appears in', count: part.placements.length),
          ...part.placements.map(
            (pl) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text(pl.refNo)),
              title: Text('${pl.assemblyCode} · ${pl.assemblyName}'),
              subtitle: Text(pl.machineLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DiagramScreen(assemblyId: pl.assemblyId, highlightItemId: pl.itemId),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.number, required this.onTap});

  final PartNumberView number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        number.isPrimary ? Icons.star : Icons.tag,
        color: number.isPrimary ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        number.value,
        style: theme.textTheme.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      ),
      subtitle: Text([number.kind, if (number.brand != null) number.brand!].join(' · ')),
      trailing: const Icon(Icons.copy, size: 18),
      onTap: onTap,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.count});
  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text('$count', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

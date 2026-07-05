import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../browse/diagram_screen.dart';
import 'data/lookup_repository.dart';
import 'models.dart';
import 'recent_parts_store.dart';

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
    // Any way a part gets opened (search, recent list, assistant citation,
    // diagram tap) counts as a recent lookup.
    context.read<RecentPartsStore>().record(widget.partId);
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

        ..._statusBanner(context, part),

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

        if (part.substitutes.isNotEmpty) ...[
          _SectionTitle('Substitutes', count: part.substitutes.length),
          ...part.substitutes.map(
            (s) => _substituteTile(context, part, s),
          ),
        ],

        if (part.placements.isNotEmpty) ...[
          _SectionTitle('Appears in', count: part.placements.length),
          ...part.placements.map(
            (pl) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text(pl.refNo)),
              title: Text('${pl.assemblyCode} · ${pl.assemblyName}'),
              subtitle: Text(
                pl.applicability == null
                    ? pl.machineLabel
                    : '${pl.machineLabel}\nFits: ${pl.applicability}',
              ),
              isThreeLine: pl.applicability != null,
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

  void _openPart(String partId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PartDetailScreen(partId: partId)),
    );
  }

  /// A callout at the top: green when this part IS the current replacement, or a
  /// "superseded" pointer to whichever substitute is current. Nothing when the
  /// cluster has no designated current part.
  List<Widget> _statusBanner(BuildContext context, PartDetail part) {
    final theme = Theme.of(context);
    if (part.isCurrentReplacement) {
      return [
        _Banner(
          icon: Icons.verified,
          color: theme.colorScheme.primary,
          title: 'Current replacement',
          subtitle: 'Use this part — the ones it interchanges with are obsolete.',
        ),
      ];
    }
    SubstituteView? current;
    for (final s in part.substitutes) {
      if (s.isCurrent) {
        current = s;
        break;
      }
    }
    if (current != null) {
      final label = [
        if (current.primaryNumber != null) current.primaryNumber!,
        current.name,
      ].join(' · ');
      final currentId = current.partId;
      return [
        _Banner(
          icon: Icons.info_outline,
          color: theme.colorScheme.tertiary,
          title: 'Superseded — obsolete',
          subtitle: 'Current replacement: $label',
          onTap: () => _openPart(currentId),
        ),
      ];
    }
    return const [];
  }

  Widget _substituteTile(BuildContext context, PartDetail part, SubstituteView s) {
    final theme = Theme.of(context);
    // "Obsolete" only reads true when the cluster has a designated current part
    // (this one or a sibling); otherwise the parts are simply interchangeable.
    final hasCurrent = part.isCurrentReplacement || part.substitutes.any((o) => o.isCurrent);
    final String status;
    if (s.isCurrent) {
      status = 'Current replacement';
    } else if (hasCurrent) {
      status = 'Obsolete';
    } else {
      status = 'Interchangeable';
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        s.isCurrent ? Icons.star : Icons.swap_horiz,
        color: s.isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        [if (s.primaryNumber != null) s.primaryNumber!, s.name].join(' · '),
      ),
      subtitle: Text(s.note == null ? status : '$status · ${s.note}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openPart(s.partId),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall?.copyWith(color: color)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                if (onTap != null) Icon(Icons.chevron_right, color: color),
              ],
            ),
          ),
        ),
      ),
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

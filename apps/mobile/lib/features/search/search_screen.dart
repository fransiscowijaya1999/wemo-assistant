import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../browse/diagram_screen.dart';
import 'data/lookup_repository.dart';
import 'models.dart';
import 'part_detail_screen.dart';
import 'recent_parts_store.dart';

/// Search tab: resolve any part number, name, or local term to the canonical
/// part, and find diagram assemblies by code/name/machine — fully offline
/// against the replica. Empty state shows the clerk's recently viewed parts
/// (the counter repeats the same lookups).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<PartSearchResult> _results = const [];
  List<AssemblySearchResult> _assemblies = const [];
  bool _loading = false;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _run(value));
  }

  Future<void> _run(String value) async {
    final q = value.trim();
    final repo = context.read<LookupRepository>();
    setState(() {
      _query = q;
      _loading = q.isNotEmpty;
    });
    final (res, asm) = q.isEmpty
        ? (<PartSearchResult>[], <AssemblySearchResult>[])
        : await (repo.search(q), repo.searchAssemblies(q)).wait;
    if (!mounted) return;
    setState(() {
      _results = res;
      _assemblies = asm;
      _loading = false;
    });
  }

  void _open(PartSearchResult r) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PartDetailScreen(partId: r.partId)),
    );
  }

  void _openAssembly(AssemblySearchResult a) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DiagramScreen(assemblyId: a.assemblyId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              key: const Key('searchField'),
              controller: _controller,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Part number, name, diagram, or local term',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _run('');
                        },
                      ),
              ),
            ),
          ),
          Expanded(child: _resultsArea(context)),
        ],
      ),
    );
  }

  Widget _resultsArea(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_query.isEmpty) return _RecentList(onOpen: _open);
    if (_results.isEmpty && _assemblies.isEmpty) {
      return _Hint('No matches for “$_query”.');
    }
    return ListView(
      children: [
        if (_assemblies.isNotEmpty) ...[
          const _SectionHeader('Diagrams'),
          for (final a in _assemblies)
            _AssemblyTile(result: a, onTap: () => _openAssembly(a)),
        ],
        if (_results.isNotEmpty) ...[
          if (_assemblies.isNotEmpty) const _SectionHeader('Parts'),
          for (final r in _results)
            _ResultTile(result: r, onTap: () => _open(r)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _AssemblyTile extends StatelessWidget {
  const _AssemblyTile({required this.result, required this.onTap});

  final AssemblySearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = result;
    final parts = a.partCount == 1 ? '1 part' : '${a.partCount} parts';
    return ListTile(
      leading: Icon(
        a.hasImage ? Icons.image_outlined : Icons.list_alt,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text('${a.code}  ·  ${a.name}'),
      subtitle: Text('${a.machineLabel}  ·  $parts'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.onTap});

  final PartSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final matchedElsewhere = r.matchedNumber != null && r.matchedNumber != r.primaryNumber;
    final firstLine = [
      if (r.primaryNumber != null) r.primaryNumber!,
      if (matchedElsewhere) 'matched ${r.matchedNumber}'
      else if (r.matchedAlias != null) '“${r.matchedAlias}”',
    ].join('  ·  ');
    final lines = [
      if (firstLine.isNotEmpty) firstLine,
      if (r.machines != null) r.machines!,
    ];
    return ListTile(
      title: Text(r.name),
      subtitle: lines.isEmpty
          ? null
          : Text(lines.join('\n'), maxLines: 2, overflow: TextOverflow.ellipsis),
      isThreeLine: lines.length > 1,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Empty-query state: recently viewed parts, resolved fresh from the replica.
class _RecentList extends StatelessWidget {
  const _RecentList({required this.onOpen});

  final void Function(PartSearchResult) onOpen;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecentPartsStore>();
    final ids = store.ids;
    if (ids.isEmpty) {
      return const _Hint('Search a part number, name, diagram, or local term (e.g. “paking”).');
    }
    return FutureBuilder<List<PartSearchResult>>(
      // ids in the key so the list refetches when a new part is viewed.
      key: ValueKey(ids.join(',')),
      future: context.read<LookupRepository>().partsByIds(ids),
      builder: (context, snap) {
        final items = snap.data;
        if (items == null) return const SizedBox.shrink();
        if (items.isEmpty) {
          return const _Hint('Search a part number, name, diagram, or local term (e.g. “paking”).');
        }
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Recent', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  TextButton(onPressed: store.clear, child: const Text('Clear')),
                ],
              ),
            ),
            for (final r in items)
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(r.name),
                subtitle: r.primaryNumber == null ? null : Text(r.primaryNumber!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onOpen(r),
              ),
          ],
        );
      },
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

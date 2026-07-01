import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/lookup_repository.dart';
import 'models.dart';
import 'part_detail_screen.dart';

/// Search tab: resolve any part number, name, or local term to the canonical
/// part — fully offline against the replica.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<PartSearchResult> _results = const [];
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
    final res = q.isEmpty ? <PartSearchResult>[] : await repo.search(q);
    if (!mounted) return;
    setState(() {
      _results = res;
      _loading = false;
    });
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
                hintText: 'Part number, name, or local term',
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
    if (_query.isEmpty) {
      return const _Hint('Type a part number, a name, or a local term (e.g. “paking”).');
    }
    if (_results.isEmpty) return _Hint('No matches for “$_query”.');
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final r = _results[i];
        final matchedElsewhere =
            r.matchedNumber != null && r.matchedNumber != r.primaryNumber;
        return ListTile(
          title: Text(r.name),
          subtitle: Text([
            if (r.primaryNumber != null) r.primaryNumber!,
            if (matchedElsewhere) 'matched ${r.matchedNumber}',
          ].join('  ·  ')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PartDetailScreen(partId: r.partId)),
          ),
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

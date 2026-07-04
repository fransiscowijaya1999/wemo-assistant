import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/catalog_repository.dart';
import 'machine_browse_screen.dart';
import 'models.dart';

/// Browse tab root: pick a machine, then browse its diagrams by group.
/// A filter field lets the clerk jump to a model by name/year once the
/// catalog grows past a screenful — hidden while the replica is empty.
class MachineListScreen extends StatefulWidget {
  const MachineListScreen({super.key});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Case-insensitive match over the visible fields (brand, model, year).
  bool _matches(MachineListItem m, String q) {
    final haystack = '${m.label} ${m.yearLabel ?? ''}'.toLowerCase();
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CatalogRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Browse — Machines')),
      body: StreamBuilder<List<MachineListItem>>(
        stream: repo.watchMachines(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final machines = snap.data!;
          if (machines.isEmpty) return const _Empty();

          final q = _query.trim().toLowerCase();
          final filtered =
              q.isEmpty ? machines : machines.where((m) => _matches(m, q)).toList();

          return Column(
            children: [
              _SearchField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _NoMatches(query: _query.trim())
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) => _MachineTile(machine: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Filter machines…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
                  onPressed: onClear,
                ),
        ),
      ),
    );
  }
}

class _MachineTile extends StatelessWidget {
  const _MachineTile({required this.machine});

  final MachineListItem machine;

  @override
  Widget build(BuildContext context) {
    final m = machine;
    final year = m.yearLabel;
    final total = m.engineCount + m.frameCount;
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.two_wheeler)),
      title: Text(m.label),
      subtitle: Text([
        ?year,
        '$total diagram${total == 1 ? '' : 's'}',
      ].join(' · ')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MachineBrowseScreen(machine: m)),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No machines match “$query”.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            const Text(
              'No machines yet.\nOpen the Sync tab and pull the catalog.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

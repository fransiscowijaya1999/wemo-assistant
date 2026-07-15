import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../browse/data/catalog_repository.dart';
import '../../browse/models.dart';

/// Screen for searching and selecting a machine.
class MachineSearchScreen extends StatefulWidget {
  const MachineSearchScreen({super.key});

  @override
  State<MachineSearchScreen> createState() => _MachineSearchScreenState();
}

class _MachineSearchScreenState extends State<MachineSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(MachineListItem m, String q) {
    if (q.isEmpty) return true;
    final haystack = '${m.label} ${m.yearLabel ?? ''}'.toLowerCase();
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CatalogRepository>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Machine'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search machines...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<MachineListItem>>(
        stream: repo.watchMachines(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final machines = snapshot.data!;
          if (machines.isEmpty) {
            return const Center(child: Text('No machines available'));
          }

          final filtered = machines.where((m) => _matches(m, _query)).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No matching machines found'));
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final m = filtered[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.two_wheeler)),
                title: Text(m.label),
                subtitle: Text(m.yearLabel ?? ''),
                onTap: () => Navigator.pop(context, m.id),
              );
            },
          );
        },
      ),
    );
  }
}

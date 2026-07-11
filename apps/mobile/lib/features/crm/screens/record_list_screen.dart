import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/db/app_database.dart';
import '../data/record_repository.dart';
import 'record_detail_screen.dart';
import 'record_edit_screen.dart';

/// Screen that lists maintenance records with filtering.
class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key, this.customerId, this.vehicleId});

  final String? customerId;
  final String? vehicleId;

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  String _filterType = 'all';
  List<MaintenanceRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final repository = RecordRepository(db);

    try {
      List<MaintenanceRecord> records;
      if (widget.customerId != null) {
        records = await repository.getRecordsForCustomer(widget.customerId!);
      } else if (widget.vehicleId != null) {
        records = await repository.getRecordsForVehicle(widget.vehicleId!);
      } else {
        records = await repository.getAllRecords();
      }

      // Apply type filter
      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading records: $e')),
        );
      }
    }
  }

  List<MaintenanceRecord> _getFilteredRecords() {
    if (_filterType == 'all') return _records;
    return _records.where((r) => r.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();
    final title = widget.customerId != null
        ? 'Customer Records'
        : widget.vehicleId != null
            ? 'Vehicle Records'
            : 'All Records';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Filter dropdown
          DropdownButton<String>(
            value: _filterType,
            items: [
              const DropdownMenuItem(value: 'all', child: Text('All')),
              const DropdownMenuItem(value: 'service', child: Text('Service')),
              const DropdownMenuItem(value: 'purchase', child: Text('Purchase')),
            ],
            onChanged: (value) => setState(() => _filterType = value!),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (widget.customerId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecordEditScreen(customerId: widget.customerId!),
                  ),
                ).then((_) => _loadRecords());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please open from a customer to add records')),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No ${_filterType == 'all' ? '' : _filterType} records found'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          record.type == 'service' ? Icons.build : Icons.shopping_cart,
                          color: record.type == 'service' ? Colors.blue : Colors.green,
                        ),
                        title: Text(record.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDate(record.date)),
                            if (record.invoiceNumber != null) Text('Invoice: ${record.invoiceNumber}'),
                            if (record.totalAmount != null) Text('Total: IDR ${record.totalAmount}'),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecordDetailScreen(recordId: record.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(int? timestampMs) {
    if (timestampMs == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

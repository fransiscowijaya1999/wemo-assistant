import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/db/app_database.dart';
import '../data/vehicle_repository.dart';
import '../data/record_repository.dart';
import 'vehicle_edit_screen.dart';
import 'record_edit_screen.dart';
import 'record_detail_screen.dart';

/// Screen that shows vehicle details and its maintenance records.
class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final vehicleRepo = VehicleRepository(db);
    final recordRepo = RecordRepository(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VehicleEditScreen(),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<({CustomerVehicle vehicle, Customer? customer, Machine? machine})?>(
        future: vehicleRepo.getVehicleWithDetails(widget.vehicleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Vehicle not found'));
          }

          final vehicle = data.vehicle;
          final customer = data.customer;
          final machine = data.machine;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle info card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vehicle name/identification
                              Text(
                                vehicle.nickname ?? vehicle.licensePlate ?? 'Vehicle',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              
                              // Machine info
                              if (machine != null) ...[
                                Text('${machine.brand} ${machine.model}'),
                                if (machine.typeCode != null) Text('Type: ${machine.typeCode}'),
                                const SizedBox(height: 4),
                              ],
                              
                              // Vehicle details
                              if (vehicle.year != null) Text('Year: ${vehicle.year}'),
                              if (vehicle.licensePlate != null) Text('License: ${vehicle.licensePlate}'),
                              if (vehicle.frameNumber != null) Text('Frame: ${vehicle.frameNumber}'),
                              
                              // Customer info
                              if (customer != null) ...[
                                const Divider(height: 16),
                                Text('Owner: ${customer.name}'),
                                if (customer.phone != null) Text('Phone: ${customer.phone}'),
                              ],
                              
                              // Notes
                              if (vehicle.notes != null && vehicle.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('Notes: ${vehicle.notes}'),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Records section
                      Text('Maintenance Records', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              
              // Records list
              FutureBuilder<List<MaintenanceRecord>>(
                future: recordRepo.getRecordsForVehicle(widget.vehicleId),
                builder: (context, recordsSnapshot) {
                  if (recordsSnapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  }
                  
                  final records = recordsSnapshot.data ?? [];
                  
                  if (records.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No maintenance records for this vehicle yet.'),
                      ),
                    );
                  }
                  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final record = records[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            title: Text(record.description),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${record.type} - ${_formatDate(record.date)}'),
                                if (record.invoiceNumber != null) Text('Invoice: ${record.invoiceNumber}'),
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
                      childCount: records.length,
                    ),
                  );
                },
              ),
              
              // Add record button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Record for This Vehicle'),
                    onPressed: () {
                      if (vehicle != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecordEditScreen(
                              customerId: vehicle.customerId,
                              vehicleId: widget.vehicleId,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/db/app_database.dart';
import '../data/customer_repository.dart';
import '../data/vehicle_repository.dart';
import '../data/record_repository.dart';
import 'vehicle_edit_screen.dart';
import 'customer_edit_screen.dart';
import 'record_edit_screen.dart';
import 'vehicle_detail_screen.dart';
import 'record_detail_screen.dart';

/// Screen that shows customer details, vehicles, and records.
class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final customerRepo = CustomerRepository(db);
    final vehicleRepo = VehicleRepository(db);
    final recordRepo = RecordRepository(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerEditScreen(customerId: widget.customerId),
              ),
            ).then((value) {
              if (value == 'deleted') {
                Navigator.pop(context);
              } else {
                setState(() {});
              }
            }),
          ),
        ],
      ),
      body: FutureBuilder<({Customer customer, List<CustomerVehicle> vehicles})?>(
        future: customerRepo.getCustomerWithVehicles(widget.customerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Customer not found'));
          }

          final customer = data.customer;
          final vehicles = data.vehicles;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer.name, style: Theme.of(context).textTheme.titleLarge),
                              if (customer.phone != null) Text('Phone: ${customer.phone}'),
                              if (customer.phoneAlt != null) Text('Alt Phone: ${customer.phoneAlt}'),
                              if (customer.email != null) Text('Email: ${customer.email}'),
                              if (customer.address != null) Text('Address: ${customer.address}'),
                              if (customer.tag != null) Chip(label: Text(customer.tag!)),
                              if (customer.notes != null && customer.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('Notes: ${customer.notes}'),
                                ),
                            ].where((w) => w is! Text || ((w as Text).data?.isNotEmpty ?? false)).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Vehicles section
                      Text('Vehicles (${vehicles.length})', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              
              // Vehicles list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final vehicle = vehicles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(vehicle.nickname ?? vehicle.licensePlate ?? 'Vehicle ${index + 1}'),
                        subtitle: FutureBuilder<Machine?>(
                          future: _getMachine(db, vehicle.machineId),
                          builder: (context, machineSnapshot) {
                            final machine = machineSnapshot.data;
                            return Text(machine != null ? '${machine.brand} ${machine.model}' : vehicle.machineId);
                          },
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VehicleDetailScreen(vehicleId: vehicle.id),
                          ),
                        ).then((_) => setState(() {})),
                      ),
                    );
                  },
                  childCount: vehicles.length,
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              // Add vehicle button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vehicle'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VehicleEditScreen(customerId: widget.customerId),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              
              // Records section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Maintenance Records', style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              
              // Records list
              FutureBuilder<List<MaintenanceRecord>>(
                future: recordRepo.getRecordsForCustomer(widget.customerId),
                builder: (context, recordsSnapshot) {
                  if (recordsSnapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  }
                  
                  final records = recordsSnapshot.data ?? [];
                  
                  if (records.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No maintenance records yet.'),
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
                            ).then((_) => setState(() {})),
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
                    label: const Text('Add Record'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordEditScreen(customerId: widget.customerId),
                      ),
                    ),
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

  Future<Machine?> _getMachine(AppDatabase db, String machineId) async {
    try {
      return await (db.select(db.machines)..where((t) => t.id.equals(machineId))).getSingleOrNull();
    } catch (_) {
      return null;
    }
  }

  String _formatDate(int? timestampMs) {
    if (timestampMs == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

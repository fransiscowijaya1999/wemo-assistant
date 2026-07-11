import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/db/app_database.dart';
import '../data/customer_repository.dart';
import 'customer_detail_screen.dart';
import 'customer_edit_screen.dart';

/// Screen that lists all customers with search functionality.
class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final repository = CustomerRepository(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomerEditScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Customer>>(
        future: repository.getAllCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final customers = snapshot.data ?? [];

          if (customers.isEmpty) {
            return const Center(
              child: Text('No customers found. Tap + to add a customer.'),
            );
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(customer.name),
                subtitle: customer.phone != null ? Text(customer.phone!) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerDetailScreen(customerId: customer.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


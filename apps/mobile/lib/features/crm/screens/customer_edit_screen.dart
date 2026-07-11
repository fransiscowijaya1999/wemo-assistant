import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/db/app_database.dart';
import '../data/customer_repository.dart';

/// Screen for creating or editing a customer.
class CustomerEditScreen extends StatefulWidget {
  const CustomerEditScreen({super.key, this.customerId});

  final String? customerId;

  @override
  State<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends State<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _phoneAltController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _phoneAltController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _notesController = TextEditingController();
    _tagController = TextEditingController();

    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _phoneAltController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomer() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final repository = CustomerRepository(db);
    final customer = await repository.getCustomer(widget.customerId!);

    if (customer != null && mounted) {
      setState(() {
        _nameController.text = customer.name;
        _phoneController.text = customer.phone ?? '';
        _phoneAltController.text = customer.phoneAlt ?? '';
        _emailController.text = customer.email ?? '';
        _addressController.text = customer.address ?? '';
        _notesController.text = customer.notes ?? '';
        _tagController.text = customer.tag ?? '';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = Provider.of<AppDatabase>(context, listen: false);
    final repository = CustomerRepository(db);

    final customerId = widget.customerId != null
        ? await repository.updateCustomer(
            id: widget.customerId!,
            name: _nameController.text,
            phone: _phoneController.text.isEmpty ? null : _phoneController.text,
            phoneAlt: _phoneAltController.text.isEmpty ? null : _phoneAltController.text,
            email: _emailController.text.isEmpty ? null : _emailController.text,
            address: _addressController.text.isEmpty ? null : _addressController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            tag: _tagController.text.isEmpty ? null : _tagController.text,
          )
        : await repository.createCustomer(
            name: _nameController.text,
            phone: _phoneController.text.isEmpty ? null : _phoneController.text,
            phoneAlt: _phoneAltController.text.isEmpty ? null : _phoneAltController.text,
            email: _emailController.text.isEmpty ? null : _emailController.text,
            address: _addressController.text.isEmpty ? null : _addressController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            tag: _tagController.text.isEmpty ? null : _tagController.text,
          );

    if (customerId != null && mounted) {
      Navigator.pop(context, customerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customerId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'New Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneAltController,
                decoration: const InputDecoration(labelText: 'Alternate Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(labelText: 'Tag'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

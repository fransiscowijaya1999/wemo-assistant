import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/db/app_database.dart';
import '../data/record_repository.dart';
import '../data/vehicle_repository.dart';
import '../crm.dart';
import 'record_item_edit_screen.dart';

/// Screen for creating or editing a maintenance record.
class RecordEditScreen extends StatefulWidget {
  const RecordEditScreen({super.key, this.recordId, required this.customerId, this.vehicleId});

  final String? recordId;
  final String customerId;
  final String? vehicleId;

  @override
  State<RecordEditScreen> createState() => _RecordEditScreenState();
}

class _RecordEditScreenState extends State<RecordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _invoiceNumberController;
  late TextEditingController _totalAmountController;
  late TextEditingController _notesController;

  String _type = 'service';
  String? _selectedVehicleId;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _invoiceNumberController = TextEditingController();
    _totalAmountController = TextEditingController();
    _notesController = TextEditingController();

    _selectedVehicleId = widget.vehicleId;
    _date = DateTime.now();

    if (widget.recordId != null) {
      _loadRecord();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _invoiceNumberController.dispose();
    _totalAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final repository = RecordRepository(db);
    final record = await repository.getRecord(widget.recordId!);

    if (record != null && mounted) {
      setState(() {
        _descriptionController.text = record.description;
        _type = record.type;
        _selectedVehicleId = record.customerVehicleId;
        _invoiceNumberController.text = record.invoiceNumber ?? '';
        _totalAmountController.text = record.totalAmount?.toString() ?? '';
        _notesController.text = record.notes ?? '';
        _date = record.date != null ? DateTime.fromMillisecondsSinceEpoch(record.date!) : DateTime.now();
      });
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  Future<void> _selectVehicle() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final vehicleRepo = VehicleRepository(db);
    final vehicles = await vehicleRepo.getVehiclesForCustomer(widget.customerId);

    if (vehicles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No vehicles found for this customer')),
        );
      }
      return;
    }

    if (vehicles.length == 1) {
      setState(() {
        _selectedVehicleId = vehicles.first.id;
      });
      return;
    }

    // Show vehicle selection dialog
    final selectedId = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Vehicle'),
        children: vehicles.map((v) => SimpleDialogOption(
          child: Text(v.nickname ?? v.licensePlate ?? v.id),
          onPressed: () => Navigator.pop(context, v.id),
        )).toList(),
      ),
    );

    if (selectedId != null && mounted) {
      setState(() {
        _selectedVehicleId = selectedId;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = Provider.of<AppDatabase>(context, listen: false);
    final repository = RecordRepository(db);

    final recordId = widget.recordId != null
        ? await repository.updateRecord(
            id: widget.recordId!,
            customerId: widget.customerId,
            customerVehicleId: _selectedVehicleId,
            type: _type,
            date: _date,
            description: _descriptionController.text,
            invoiceNumber: _invoiceNumberController.text.isEmpty ? null : _invoiceNumberController.text,
            totalAmount: _totalAmountController.text.isEmpty ? null : int.parse(_totalAmountController.text),
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          )
        : await repository.createRecord(
            customerId: widget.customerId,
            customerVehicleId: _selectedVehicleId,
            type: _type,
            date: _date,
            description: _descriptionController.text,
            invoiceNumber: _invoiceNumberController.text.isEmpty ? null : _invoiceNumberController.text,
            totalAmount: _totalAmountController.text.isEmpty ? null : int.parse(_totalAmountController.text),
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );

    if (recordId != null && mounted) {
      Navigator.pop(context, recordId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recordId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Record' : 'New Record'),
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
              // Type selection
              DropdownButtonFormField<String>(
                value: _type,
                items: kMaintenanceRecordTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.capitalize()),
                )).toList(),
                onChanged: (value) => setState(() => _type = value!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 16),

              // Date selection
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectDate,
                      child: Text(
                        _date != null 
                          ? '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'
                          : 'Select Date',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vehicle selection
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectVehicle,
                      child: Text(
                        _selectedVehicleId == null 
                          ? 'Select Vehicle (optional)' 
                          : 'Vehicle: $_selectedVehicleId',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description *'),
                validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Invoice number
              TextFormField(
                controller: _invoiceNumberController,
                decoration: const InputDecoration(labelText: 'Invoice Number'),
              ),
              const SizedBox(height: 16),

              // Total amount
              TextFormField(
                controller: _totalAmountController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _save,
                child: const Text('Save Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension for string capitalization
extension on String {
  String capitalize() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}


import 'package:flutter/material.dart';
import '../../models/customer.dart';
import 'package:uuid/uuid.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer; // ✅ NEW

  const AddCustomerScreen({Key? key, this.customer}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ✅ Prefill when editing
    if (widget.customer != null) {
      nameController.text = widget.customer!.name;
      phoneController.text = widget.customer!.phone;
      addressController.text = widget.customer!.address ?? '';
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id ?? const Uuid().v4(), // ✅ preserve ID
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        totalPaid: widget.customer?.totalPaid ?? 0,
        totalSpent: widget.customer?.totalSpent ?? 0,
      );

      Navigator.pop(context, customer);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Customer" : "Add Customer")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Customer Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter phone" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Address (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? "Update Customer" : "Save Customer"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../../models/customer.dart';
// import 'package:uuid/uuid.dart';

// class AddCustomerScreen extends StatefulWidget {
//   final Customer? customer; // ✅ NEW

//   const AddCustomerScreen({Key? key, this.customer}) : super(key: key);

//   @override
//   State<AddCustomerScreen> createState() => _AddCustomerScreenState();
// }

// class _AddCustomerScreenState extends State<AddCustomerScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final addressController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     // ✅ Prefill when editing
//     if (widget.customer != null) {
//       nameController.text = widget.customer!.name;
//       phoneController.text = widget.customer!.phone;
//       addressController.text = widget.customer!.address ?? '';
//     }
//   }

//   void _save() {
//     if (_formKey.currentState!.validate()) {
//       final customer = Customer(
//         id: widget.customer?.id ?? const Uuid().v4(), // ✅ preserve ID
//         name: nameController.text.trim(),
//         phone: phoneController.text.trim(),
//         address: addressController.text.trim().isEmpty
//             ? null
//             : addressController.text.trim(),
//         totalPaid: widget.customer?.totalPaid ?? 0,
//         totalSpent: widget.customer?.totalSpent ?? 0,
//       );

//       Navigator.pop(context, customer);
//     }
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     phoneController.dispose();
//     addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.customer != null;

//     return Scaffold(
//       appBar: AppBar(title: Text(isEdit ? "Edit Customer" : "Add Customer")),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: "Customer Name",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     v == null || v.trim().isEmpty ? "Enter name" : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(
//                   labelText: "Phone",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     v == null || v.trim().isEmpty ? "Enter phone" : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: addressController,
//                 decoration: const InputDecoration(
//                   labelText: "Address (optional)",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _save,
//                 child: Text(isEdit ? "Update Customer" : "Save Customer"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../models/customer.dart';
import 'package:uuid/uuid.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;

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

    if (widget.customer != null) {
      nameController.text = widget.customer!.name;
      phoneController.text = widget.customer!.phone;
      addressController.text = widget.customer!.address ?? '';
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id ?? const Uuid().v4(),
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Modern Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEdit ? "Edit Customer" : "Add Customer",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 Form Section
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _modernField(
                        controller: nameController,
                        label: "Customer Name",
                        icon: Icons.person_outline,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Enter name" : null,
                      ),
                      const SizedBox(height: 18),
                      _modernField(
                        controller: phoneController,
                        label: "Phone Number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Enter phone"
                            : null,
                      ),
                      const SizedBox(height: 18),
                      _modernField(
                        controller: addressController,
                        label: "Address (Optional)",
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔹 Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isEdit ? "Update Customer" : "Save Customer",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🔹 Modern Styled TextField
  Widget _modernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

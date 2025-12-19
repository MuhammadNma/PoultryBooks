import 'package:flutter/material.dart';
import '../../models/customer_transaction.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  final String customerId;

  const AddTransactionScreen({Key? key, required this.customerId})
      : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final crates = TextEditingController();
  final pieces = TextEditingController();
  final pricePerCrate = TextEditingController();
  final amountPaid = TextEditingController();

  @override
  void dispose() {
    crates.dispose();
    pieces.dispose();
    pricePerCrate.dispose();
    amountPaid.dispose();
    super.dispose();
  }

  void _save() {
    final c = int.tryParse(crates.text) ?? 0;
    final p = int.tryParse(pieces.text) ?? 0;
    final price = double.tryParse(pricePerCrate.text) ?? 0.0;
    final paid = double.tryParse(amountPaid.text) ?? 0.0;

    final total = (c * price) + (p * (price / 30));

    final tx = CustomerTransaction(
      id: const Uuid().v4(),
      customerId: widget.customerId,
      crates: c,
      pieces: p,
      pricePerCrate: price,
      totalAmount: total,
      amountPaid: paid,
      date: DateTime.now(),
    );

    Navigator.pop(context, tx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: crates,
              decoration: const InputDecoration(labelText: "Crates"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pieces,
              decoration: const InputDecoration(labelText: "Egg pieces"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pricePerCrate,
              decoration: const InputDecoration(labelText: "Price per crate"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: amountPaid,
              decoration: const InputDecoration(labelText: "Amount paid"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text("Save Transaction"),
            )
          ],
        ),
      ),
    );
  }
}

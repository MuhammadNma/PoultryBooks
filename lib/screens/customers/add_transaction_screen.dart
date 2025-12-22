import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/customer_transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final String customerId;

  const AddTransactionScreen({Key? key, required this.customerId})
      : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final cratesCtrl = TextEditingController();
  final piecesCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final paidCtrl = TextEditingController();

  bool _userEditedTotal = false;

  @override
  void initState() {
    super.initState();
    cratesCtrl.addListener(_recalculateTotal);
    piecesCtrl.addListener(_recalculateTotal);
    priceCtrl.addListener(_recalculateTotal);
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  void _recalculateTotal() {
    if (_userEditedTotal) return;

    final crates = _parse(cratesCtrl);
    final pieces = _parse(piecesCtrl);
    final cratePrice = _parse(priceCtrl);

    if (cratePrice <= 0) {
      totalCtrl.text = '';
      return;
    }

    final singleEggPrice = cratePrice / 30;
    final total = (crates * cratePrice) + (pieces * singleEggPrice);

    totalCtrl.text = total.toStringAsFixed(2);
  }

  void _resetAutoCalculation() {
    setState(() {
      _userEditedTotal = false;
    });
    _recalculateTotal();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final tx = CustomerTransaction(
      id: const Uuid().v4(),
      customerId: widget.customerId,
      crates: _parse(cratesCtrl).toInt(),
      pieces: _parse(piecesCtrl).toInt(),
      pricePerCrate: _parse(priceCtrl),
      totalAmount: _parse(totalCtrl),
      amountPaid: _parse(paidCtrl), // empty → 0
      date: DateTime.now(),
    );

    Navigator.pop(context, tx);
  }

  @override
  void dispose() {
    cratesCtrl.dispose();
    piecesCtrl.dispose();
    priceCtrl.dispose();
    totalCtrl.dispose();
    paidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _numberField(
                controller: cratesCtrl,
                label: 'Crates',
              ),
              const SizedBox(height: 12),

              _numberField(
                controller: piecesCtrl,
                label: 'Egg Pieces',
                hint: 'Optional',
              ),
              const SizedBox(height: 12),

              _numberField(
                controller: priceCtrl,
                label: 'Price per Crate',
                prefix: '₦',
              ),
              const SizedBox(height: 12),

              /// TOTAL (AUTO)
              TextFormField(
                controller: totalCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total Amount',
                  prefixText: '₦',
                  hintText: 'Auto-calculated',
                  suffixIcon: _userEditedTotal
                      ? IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset auto calculation',
                          onPressed: _resetAutoCalculation,
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter total amount' : null,
                onChanged: (_) {
                  if (!_userEditedTotal) {
                    setState(() => _userEditedTotal = true);
                  }
                },
              ),
              const SizedBox(height: 12),

              /// AMOUNT PAID (MANUAL)
              TextFormField(
                controller: paidCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount Paid',
                  prefixText: '₦',
                  hintText: 'Leave empty if not paid',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

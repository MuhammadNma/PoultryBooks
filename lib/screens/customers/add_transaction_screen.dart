import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/customer_transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final String customerId;
  final CustomerTransaction? transaction;

  const AddTransactionScreen({
    Key? key,
    required this.customerId,
    this.transaction,
  }) : super(key: key);

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
  DateTime selectedDate = DateTime.now();

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final tx = widget.transaction!;
      cratesCtrl.text = tx.crates.toString();
      piecesCtrl.text = tx.pieces.toString();
      priceCtrl.text = tx.pricePerCrate.toString();
      totalCtrl.text = tx.totalAmount.toString();
      paidCtrl.text = tx.amountPaid.toString();
      selectedDate = tx.date;
      _userEditedTotal = true;
    }

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

  // void _resetAutoCalculation() {
  //   setState(() => _userEditedTotal = false);
  //   _recalculateTotal();
  // }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final tx = CustomerTransaction(
      id: isEditing ? widget.transaction!.id : const Uuid().v4(),
      customerId: widget.customerId,
      crates: _parse(cratesCtrl).toInt(),
      pieces: _parse(piecesCtrl).toInt(),
      pricePerCrate: _parse(priceCtrl),
      totalAmount: _parse(totalCtrl),
      amountPaid: _parse(paidCtrl),
      date: selectedDate,
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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'New Transaction'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _numberField(controller: cratesCtrl, label: 'Crates'),
                    const SizedBox(height: 16),
                    // _numberField(controller: piecesCtrl, label: 'Egg Pieces'),
                    // const SizedBox(height: 16),
                    _numberField(
                      controller: priceCtrl,
                      label: 'Price per Crate',
                      prefix: '₦ ',
                    ),
                    const SizedBox(height: 16),
                    _numberField(
                      controller: totalCtrl,
                      label: 'Total Amount',
                      prefix: '₦ ',
                    ),
                    const SizedBox(height: 16),
                    _numberField(
                      controller: paidCtrl,
                      label: 'Amount Paid',
                      prefix: '₦ ',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(
                      isEditing ? 'Update Transaction' : 'Save Transaction',
                    ),
                  ),
                ),
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
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

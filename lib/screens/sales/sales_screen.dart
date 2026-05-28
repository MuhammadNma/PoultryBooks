// lib/screens/sales/sales_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/sale_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/sale.dart';
import '../../models/customer.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../utils/formatters.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SaleProvider>().all;

    return Scaffold(
      appBar: AppBar(title: const Text('Egg Sales')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Record Sale'),
      ),
      body: sales.isEmpty
          ? _EmptyState(onAdd: () => _openForm(context, null))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sales.length,
              itemBuilder: (_, i) => _SaleTile(
                sale: sales[i],
                onTap: () => _showDetail(context, sales[i]),
              ),
            ),
    );
  }

  void _openForm(BuildContext context, Sale? sale) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => SaleFormScreen(existing: sale)));
  }

  void _showDetail(BuildContext context, Sale sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SaleDetailSheet(sale: sale),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final Sale sale;
  final VoidCallback onTap;
  const _SaleTile({required this.sale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPaid = sale.amountOwed <= 0;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              isPaid ? Colors.green.shade50 : Colors.orange.shade50,
          child: Icon(isPaid ? Icons.check_circle : Icons.pending_outlined,
              color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
              size: 20),
        ),
        title: Text(sale.customerName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${formatDate(sale.date)} · ${sale.crates} crates + ${sale.loosePieces} pcs'),
        trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatMoney(sale.totalEggIncome),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              if (!isPaid)
                Text('Owes ${formatMoney(sale.amountOwed)}',
                    style: TextStyle(fontSize: 11, color: Colors.red.shade500)),
            ]),
      ),
    );
  }
}

class _SaleDetailSheet extends StatelessWidget {
  final Sale sale;
  const _SaleDetailSheet({required this.sale});

  @override
  Widget build(BuildContext context) {
    final isPaid = sale.amountOwed <= 0;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
            Row(children: [
              Expanded(
                  child: Text(sale.customerName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              Text(formatDate(sale.date),
                  style: TextStyle(color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 16),
            _row('Crates', '${sale.crates}'),
            _row('Loose Pieces', '${sale.loosePieces}'),
            _row('Price per Crate', formatMoney(sale.pricePerCrate)),
            _row('Total Eggs', formatEggs(sale.totalEggs)),
            const Divider(height: 24),
            _row('Total Amount', formatMoney(sale.totalEggIncome)),
            _row('Amount Paid', formatMoney(sale.amountPaid)),
            _row('Balance Owed', formatMoney(sale.amountOwed),
                valueColor:
                    isPaid ? Colors.green.shade700 : Colors.red.shade600),
            if (sale.notes != null) ...[
              const SizedBox(height: 8),
              Text('Notes: ${sale.notes}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            Row(children: [
              if (!isPaid)
                Expanded(
                    child: ElevatedButton.icon(
                  onPressed: () async {
                    sale.amountPaid = sale.totalEggIncome;
                    sale.synced = false;
                    await context.read<SaleProvider>().update(sale);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Mark Fully Paid'),
                )),
              if (!isPaid) const SizedBox(width: 10),
              Expanded(
                  child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red)),
                onPressed: () async {
                  await context.read<SaleProvider>().delete(sale);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              )),
            ]),
            const SizedBox(height: 8),
          ]),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? Colors.black87)),
        ]),
      );
}

// ---- Sale Form ----
class SaleFormScreen extends StatefulWidget {
  final Sale? existing;
  const SaleFormScreen({super.key, this.existing});
  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _cratesCtrl = TextEditingController();
  final _piecesCtrl = TextEditingController(text: '0');
  final _priceCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _customerId;
  String? _customerName;
  String? _flockId;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    final settings = context.read<SettingsProvider>().settings;
    if (s != null) {
      _cratesCtrl.text = s.crates.toString();
      _piecesCtrl.text = s.loosePieces.toString();
      _priceCtrl.text = s.pricePerCrate.toStringAsFixed(0);
      _paidCtrl.text = s.amountPaid.toStringAsFixed(0);
      _notesCtrl.text = s.notes ?? '';
      _date = s.date;
      _customerId = s.customerId;
      _customerName = s.customerName;
      _flockId = s.flockId;
    } else if (settings.defaultPricePerCrate > 0) {
      _priceCtrl.text = settings.defaultPricePerCrate.toStringAsFixed(0);
    }
  }

  double get _total {
    final crates = double.tryParse(_cratesCtrl.text) ?? 0;
    final pieces = double.tryParse(_piecesCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    return (crates * price) + (pieces * (price / AppConstants.eggsPerCrate));
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
    if (p != null) setState(() => _date = p);
  }

  Future<void> _pickCustomer() async {
    final customers = context.read<CustomerProvider>().all;
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No customers yet — add one in the Customers screen')));
      return;
    }
    await showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select Customer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...customers.map((c) => ListTile(
                title: Text(c.name),
                subtitle: Text(c.phone),
                onTap: () {
                  setState(() {
                    _customerId = c.id;
                    _customerName = c.name;
                  });
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_customerId == null) {
      _show('Please select a customer');
      return;
    }
    if ((_cratesCtrl.text.isEmpty ||
            double.tryParse(_cratesCtrl.text) == null) &&
        (_piecesCtrl.text.isEmpty ||
            double.tryParse(_piecesCtrl.text) == null)) {
      _show('Enter number of crates or pieces');
      return;
    }
    if (_priceCtrl.text.isEmpty) {
      _show('Enter price per crate');
      return;
    }

    final sale = Sale(
      id: widget.existing?.id ?? const Uuid().v4(),
      date: _date,
      customerId: _customerId!,
      customerName: _customerName!,
      crates: int.tryParse(_cratesCtrl.text) ?? 0,
      loosePieces: int.tryParse(_piecesCtrl.text) ?? 0,
      pricePerCrate: double.tryParse(_priceCtrl.text) ?? 0,
      amountPaid: double.tryParse(_paidCtrl.text) ?? 0,
      flockId: _flockId,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final provider = context.read<SaleProvider>();
    if (widget.existing != null) {
      await provider.update(sale);
    } else {
      await provider.add(sale);
    }
    if (mounted) Navigator.pop(context);
  }

  void _show(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final flocks = context.watch<FlockProvider>().active;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing != null ? 'Edit Sale' : 'Record Sale')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date
          InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined)),
                child: Text(formatDate(_date)),
              )),
          const SizedBox(height: 14),

          // Customer
          InkWell(
              onTap: _pickCustomer,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Customer',
                    prefixIcon: Icon(Icons.person_outlined)),
                child: Text(_customerName ?? 'Tap to select customer',
                    style: TextStyle(
                        color: _customerName == null
                            ? Colors.grey.shade500
                            : Colors.black87)),
              )),
          const SizedBox(height: 14),

          // Flock (optional)
          if (flocks.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: _flockId,
              decoration: const InputDecoration(
                  labelText: 'Flock (optional)',
                  prefixIcon: Icon(Icons.groups_outlined)),
              hint: const Text('No specific flock'),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('No specific flock')),
                ...flocks.map(
                    (f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
              ],
              onChanged: (v) => setState(() => _flockId = v),
            ),
            const SizedBox(height: 14),
          ],

          // Crates + pieces
          Row(children: [
            Expanded(
                child: TextField(
                    controller: _cratesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Crates', hintText: '0'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    controller: _piecesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Loose Pieces', hintText: '0'),
                    onChanged: (_) => setState(() {}))),
          ]),
          const SizedBox(height: 14),

          // Price
          TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Price per Crate (₦)', hintText: 'e.g. 1800'),
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),

          // Total preview
          if (_total > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(formatMoney(_total),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primary)),
                  ]),
            ),
          const SizedBox(height: 14),

          // Amount paid
          TextField(
              controller: _paidCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount Paid Now (₦)',
                hintText: 'Leave 0 if not paid yet',
                prefixIcon: Icon(Icons.payments_outlined),
              )),
          const SizedBox(height: 14),

          // Notes
          TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note_outlined))),
          const SizedBox(height: 28),

          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _save,
                  child: Text(widget.existing != null
                      ? 'Save Changes'
                      : 'Record Sale'))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.sell_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No sales recorded yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Record a sale when you deliver eggs to a customer.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500)),
          ]),
        ),
      );
}

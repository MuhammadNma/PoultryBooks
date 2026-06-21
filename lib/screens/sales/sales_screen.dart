// lib/screens/sales/sales_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/sale_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/sale.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../utils/formatters.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  DateTime _month = DateTime.now();

  void _prev() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _next() {
    final now = DateTime.now();
    if (_month.year == now.year && _month.month == now.month) return;
    setState(() => _month = DateTime(_month.year, _month.month + 1));
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SaleProvider>();
    final monthSales = provider.forMonth(_month.year, _month.month);
    final monthIncome = provider.totalIncomeForMonth(_month.year, _month.month);
    final totalOwing = provider.totalOwingAllCustomers;

    return Scaffold(
      appBar: AppBar(title: const Text('Egg Sales')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sales_fab',
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Record Sale'),
      ),
      body: Column(children: [
        // Month selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left)),
            Expanded(
                child: Column(children: [
              Text(formatMonthYear(_month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(formatMoney(monthIncome),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600)),
            ])),
            IconButton(
              onPressed: _isCurrentMonth ? null : _next,
              icon: Icon(Icons.chevron_right,
                  color: _isCurrentMonth ? Colors.grey.shade300 : null),
            ),
          ]),
        ),
        const Divider(height: 0),

        // Owing banner
        if (totalOwing > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded,
                  size: 14, color: Colors.orange.shade600),
              const SizedBox(width: 6),
              Expanded(
                  child: Text('Total outstanding',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600))),
              Text(formatMoney(totalOwing),
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w600)),
            ]),
          ),

        // List
        Expanded(
          child: monthSales.isEmpty
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sell_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No sales for ${formatMonthYear(_month)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Use the arrows to browse other months.',
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center),
                      ]),
                ))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: monthSales.length,
                  itemBuilder: (_, i) => _SaleTile(
                    sale: monthSales[i],
                    onTap: () => _showDetail(context, monthSales[i]),
                  ),
                ),
        ),
      ]),
    );
  }

  void _openForm(BuildContext context, Sale? sale) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => SaleFormScreen(existing: sale)));

  void _showDetail(BuildContext context, Sale sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SaleDetailSheet(
        sale: sale,
        onEdit: () {
          Navigator.pop(context); // close sheet first
          _openForm(context, sale);
        },
      ),
    );
  }
}

// ---- Sale Tile ----
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
          backgroundColor: sale.isGift
              ? Colors.purple.shade50
              : isPaid
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
          child: Icon(
            sale.isGift
                ? Icons.card_giftcard
                : isPaid
                    ? Icons.check_circle
                    : Icons.pending_outlined,
            color: sale.isGift
                ? Colors.purple.shade400
                : isPaid
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
            size: 20,
          ),
        ),
        title: Row(children: [
          Expanded(
              child: Text(sale.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis)),
          if (sale.isGift) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Text('Gift',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple.shade400,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
        subtitle: Text('${formatDate(sale.date)} · ${sale.crates} crates',
            overflow: TextOverflow.ellipsis),
        trailing: sale.isGift
            ? Icon(Icons.card_giftcard, color: Colors.purple.shade300, size: 22)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Text(formatMoney(sale.totalEggIncome),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    if (!isPaid)
                      Text('Owes ${formatMoney(sale.amountOwed)}',
                          style: TextStyle(
                              fontSize: 10, color: Colors.red.shade500),
                          overflow: TextOverflow.ellipsis),
                  ]),
      ),
    );
  }
}

// ---- Sale Detail Sheet ----
class _SaleDetailSheet extends StatelessWidget {
  final Sale sale;
  final VoidCallback onEdit;
  const _SaleDetailSheet({required this.sale, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isPaid = sale.amountOwed <= 0;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)))),

              // Header row: name + date + edit/delete icons
              Row(children: [
                Expanded(
                    child: Text(sale.customerName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis)),
                if (sale.isGift)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.card_giftcard,
                          size: 14, color: Colors.purple.shade400),
                      const SizedBox(width: 4),
                      Text('Gift',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple.shade400,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                const SizedBox(width: 8),
                // ── EDIT BUTTON ──
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Sale',
                  onPressed: onEdit,
                  color: AppTheme.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                // ── DELETE BUTTON ──
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Sale',
                  onPressed: () => _confirmDelete(context),
                  color: Colors.red.shade400,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(formatDate(sale.date),
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ]),

              const SizedBox(height: 16),

              // Detail rows
              _row('Crates', '${sale.crates} crates'),
              _row('Total Eggs',
                  '${sale.crates * AppConstants.eggsPerCrate} eggs'),
              if (!sale.isGift) ...[
                _row('Price per Crate', formatMoney(sale.pricePerCrate)),
                const Divider(height: 24),
                _row('Total Amount', formatMoney(sale.totalEggIncome)),
                _row('Amount Paid', formatMoney(sale.amountPaid)),
                _row('Balance Owed', formatMoney(sale.amountOwed),
                    valueColor:
                        isPaid ? Colors.green.shade700 : Colors.red.shade600),
              ] else ...[
                const Divider(height: 24),
                _row('Value', '₦0.00  (Gift)',
                    valueColor: Colors.purple.shade400),
              ],
              if (sale.notes != null) ...[
                const SizedBox(height: 8),
                Text('Notes: ${sale.notes}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 20),

              // Action buttons
              if (!sale.isGift && !isPaid)
                Row(children: [
                  Expanded(
                      child: OutlinedButton.icon(
                    onPressed: () => _recordPartialPayment(context, sale),
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Record Payment'),
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton.icon(
                    onPressed: () async {
                      sale.amountPaid = sale.totalEggIncome;
                      sale.synced = false;
                      await context.read<SaleProvider>().update(sale);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Mark Paid'),
                  )),
                ]),

              const SizedBox(height: 8),
            ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Sale?'),
        content: Text(
          'Delete the sale of ${sale.crates} crates for ${sale.customerName} '
          'on ${formatDate(sale.date)}? This cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<SaleProvider>().delete(sale);
              if (context.mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close sheet
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sale deleted')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _recordPartialPayment(BuildContext context, Sale sale) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Outstanding: ${formatMoney(sale.amountOwed)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Amount Paid (₦)',
              prefixIcon: Icon(Icons.payments_outlined),
              hintText: 'e.g. 5000',
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final payment = double.tryParse(ctrl.text) ?? 0;
              if (payment <= 0) return;
              final maxPay = sale.amountOwed;
              sale.amountPaid += payment.clamp(0, maxPay);
              sale.synced = false;
              await context.read<SaleProvider>().update(sale);
              if (context.mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close sheet
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${formatMoney(payment)} payment recorded')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
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
  final _priceCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _customerId, _customerName, _flockId;
  bool _isGift = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    final settings = context.read<SettingsProvider>().settings;
    if (s != null) {
      _cratesCtrl.text = s.crates.toString();
      _priceCtrl.text = s.pricePerCrate.toStringAsFixed(0);
      _paidCtrl.text = s.amountPaid.toStringAsFixed(0);
      _notesCtrl.text = s.notes ?? '';
      _date = s.date;
      _customerId = s.customerId;
      _customerName = s.customerName;
      _flockId = s.flockId;
      _isGift = s.isGift;
    } else if (settings.defaultPricePerCrate > 0) {
      _priceCtrl.text = settings.defaultPricePerCrate.toStringAsFixed(0);
    }
  }

  double get _total {
    if (_isGift) return 0;
    final crates = double.tryParse(_cratesCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    return crates * price;
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
          content: Text('No customers yet — add one in the Customers tab')));
      return;
    }
    await showModalBottomSheet(
      context: context,
      builder: (_) => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Select Customer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...customers.map((c) => ListTile(
              title: Text(c.name, overflow: TextOverflow.ellipsis),
              subtitle: Text(c.phone),
              onTap: () {
                setState(() {
                  _customerId = c.id;
                  _customerName = c.name;
                });
                Navigator.pop(context);
              },
            )),
      ]),
    );
  }

  Future<void> _save() async {
    if (_customerId == null) {
      _show('Please select a customer');
      return;
    }
    if ((int.tryParse(_cratesCtrl.text) ?? 0) <= 0) {
      _show('Enter number of crates');
      return;
    }
    if (!_isGift && _priceCtrl.text.isEmpty) {
      _show('Enter price per crate');
      return;
    }
    final paid = _isGift ? 0.0 : (double.tryParse(_paidCtrl.text) ?? 0);
    if (!_isGift && paid > _total) {
      _show(
          'Amount paid (${formatMoney(paid)}) cannot exceed total (${formatMoney(_total)})');
      return;
    }
    final sale = Sale(
      id: widget.existing?.id ?? const Uuid().v4(),
      date: _date,
      customerId: _customerId!,
      customerName: _customerName!,
      crates: int.tryParse(_cratesCtrl.text) ?? 0,
      loosePieces: 0,
      pricePerCrate: _isGift ? 0 : (double.tryParse(_priceCtrl.text) ?? 0),
      amountPaid: paid,
      flockId: _flockId,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      isGift: _isGift,
    );
    final p = context.read<SaleProvider>();
    if (widget.existing != null) {
      await p.update(sale);
    } else {
      await p.add(sale);
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
      body: ListView(padding: const EdgeInsets.all(16), children: [
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today_outlined)),
            child: Text(formatDate(_date)),
          ),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: _pickCustomer,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: const InputDecoration(
                labelText: 'Customer', prefixIcon: Icon(Icons.person_outlined)),
            child: Text(_customerName ?? 'Tap to select customer',
                style: TextStyle(
                    color: _customerName == null
                        ? Colors.grey.shade500
                        : Colors.black87),
                overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(height: 14),
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
              ...flocks.map((f) => DropdownMenuItem(
                  value: f.id,
                  child: Text(f.name, overflow: TextOverflow.ellipsis))),
            ],
            onChanged: (v) => setState(() => _flockId = v),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _cratesCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Number of Crates',
            hintText: '0',
            prefixIcon: const Icon(Icons.inventory_2_outlined),
            suffixText:
                '= ${((int.tryParse(_cratesCtrl.text) ?? 0) * AppConstants.eggsPerCrate)} eggs',
            suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),

        // Gift toggle
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isGift ? Colors.purple.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _isGift ? Colors.purple.shade200 : Colors.grey.shade200),
          ),
          child: SwitchListTile(
            value: _isGift,
            onChanged: (v) => setState(() => _isGift = v),
            activeColor: Colors.purple.shade400,
            secondary: Icon(Icons.card_giftcard,
                color: _isGift ? Colors.purple.shade400 : Colors.grey.shade400),
            title: const Text('This is a gift',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              _isGift
                  ? 'No payment expected — will not show as owing'
                  : 'Toggle on if eggs are given free of charge',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ),
        const SizedBox(height: 14),

        if (!_isGift) ...[
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Price per Crate (₦)',
                hintText: 'e.g. 1800',
                prefixIcon: Icon(Icons.sell_outlined)),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          if (_total > 0)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Expanded(
                    child: Text('Total Amount',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Text(formatMoney(_total),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primary)),
              ]),
            ),
          const SizedBox(height: 14),
          TextField(
            controller: _paidCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount Paid Now (₦)',
              hintText: 'Leave 0 if not paid yet',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: 14),
        ],

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
                child: Text(
                    widget.existing != null ? 'Save Changes' : 'Record Sale'))),
        const SizedBox(height: 40),
      ]),
    );
  }
}

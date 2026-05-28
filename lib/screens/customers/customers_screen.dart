// lib/screens/customers/customers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../models/customer.dart';
import '../../models/sale.dart';
import '../../core/app_theme.dart';
import '../../utils/formatters.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().all;
    final sales = context.watch<SaleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),
      body: customers.isEmpty
          ? _Empty(onAdd: () => _openForm(context, null))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              itemBuilder: (_, i) {
                final owing = sales.totalOwingForCustomer(customers[i].id);
                return _CustomerTile(
                  customer: customers[i],
                  owing: owing,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CustomerDetailScreen(
                              customerId: customers[i].id))),
                );
              },
            ),
    );
  }

  void _openForm(BuildContext context, Customer? c) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => CustomerFormScreen(existing: c)));
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final double owing;
  final VoidCallback onTap;
  const _CustomerTile(
      {required this.customer, required this.owing, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor:
                owing > 0 ? Colors.red.shade50 : Colors.green.shade50,
            child: Text(customer.name[0].toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: owing > 0
                        ? Colors.red.shade700
                        : Colors.green.shade700)),
          ),
          title: Text(customer.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(customer.phone,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          trailing: owing > 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                      Text('Owes',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500)),
                      Text(formatMoney(owing),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                              fontSize: 14)),
                    ])
              : Icon(Icons.check_circle,
                  color: Colors.green.shade400, size: 20),
        ),
      );
}

// ---- Customer Detail ----
class CustomerDetailScreen extends StatelessWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<CustomerProvider>().getById(customerId);
    if (customer == null)
      return const Scaffold(body: Center(child: Text('Not found')));

    final sales = context.watch<SaleProvider>().forCustomer(customerId);
    final owing =
        context.read<SaleProvider>().totalOwingForCustomer(customerId);
    final income = sales.fold(0.0, (s, e) => s + e.totalEggIncome);

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CustomerFormScreen(existing: customer))))
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(children: [
                    Icon(Icons.phone_outlined,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(customer.phone),
                  ]),
                  if (customer.address != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Text(customer.address!),
                    ]),
                  ],
                  const SizedBox(height: 16),
                  Row(children: [
                    _Stat('Total Bought', formatMoney(income),
                        Colors.grey.shade700),
                    _Stat(
                        'Outstanding',
                        formatMoney(owing),
                        owing > 0
                            ? Colors.red.shade600
                            : Colors.green.shade700),
                  ]),
                  if (owing > 0) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _markAllPaid(context, sales),
                          icon: const Icon(Icons.payments_outlined),
                          label: const Text('Mark All Paid'),
                        )),
                  ],
                ]))),
        const SizedBox(height: 16),
        const Text('Sale History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (sales.isEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: Text('No sales yet',
                      style: TextStyle(color: Colors.grey.shade500))))
        else
          ...sales.map((s) => Card(
                  child: ListTile(
                dense: true,
                title: Text(formatDate(s.date),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(
                    '${formatEggs(s.totalEggs)} · ₦${s.pricePerCrate.toStringAsFixed(0)}/crate',
                    style: const TextStyle(fontSize: 11)),
                trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatMoney(s.totalEggIncome),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      if (s.amountOwed > 0)
                        Text('Owes ${formatMoney(s.amountOwed)}',
                            style: TextStyle(
                                fontSize: 10, color: Colors.red.shade500)),
                    ]),
              ))),
        const SizedBox(height: 80),
      ]),
    );
  }

  Future<void> _markAllPaid(BuildContext context, List<Sale> sales) async {
    final provider = context.read<SaleProvider>();
    for (final s in sales.where((s) => s.amountOwed > 0)) {
      s.amountPaid = s.totalEggIncome;
      s.synced = false;
      await provider.update(s);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All payments marked as settled')));
    }
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ]));
}

// ---- Customer Form ----
class CustomerFormScreen extends StatefulWidget {
  final Customer? existing;
  const CustomerFormScreen({super.key, this.existing});
  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    if (c != null) {
      _nameCtrl.text = c.name;
      _phoneCtrl.text = c.phone;
      _addressCtrl.text = c.address ?? '';
    }
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name and phone required')));
      return;
    }
    final c = Customer(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
    );
    final p = context.read<CustomerProvider>();
    if (widget.existing != null) {
      p.update(c);
    } else {
      p.add(c);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(
                widget.existing != null ? 'Edit Customer' : 'Add Customer')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outlined))),
          const SizedBox(height: 14),
          TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone_outlined))),
          const SizedBox(height: 14),
          TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                  prefixIcon: Icon(Icons.location_on_outlined))),
          const SizedBox(height: 28),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _save,
                  child: Text(widget.existing != null
                      ? 'Save Changes'
                      : 'Add Customer'))),
          const SizedBox(height: 40),
        ]),
      );
}

class _Empty extends StatelessWidget {
  final VoidCallback onAdd;
  const _Empty({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.group_outlined, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No customers yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add customers to track egg sales and outstanding payments.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500)),
        ]),
      ));
}

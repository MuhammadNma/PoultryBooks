// lib/screens/customers/customers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../models/customer.dart';
import '../../models/sale.dart';
import '../../utils/formatters.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _showOwingOnly = false;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().all;
    final sales = context.watch<SaleProvider>();
    final totalOwing = sales.totalOwingAllCustomers;

    final filtered = customers.where((c) {
      final matchesQuery = _query.isEmpty ||
          c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.phone.contains(_query);
      final matchesOwing =
          !_showOwingOnly || sales.totalOwingForCustomer(c.id) > 0;
      return matchesQuery && matchesOwing;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'customers_fab',
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CustomerFormScreen())),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),
      body: Column(children: [
        // Owing summary banner
        if (totalOwing > 0)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${customers.where((c) => sales.totalOwingForCustomer(c.id) > 0).length} customers owe you',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(formatMoney(totalOwing),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis),
            ]),
          ),

        // Search + filter row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search customers…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          })
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilterChip(
              label: const Text('Owing', style: TextStyle(fontSize: 12)),
              selected: _showOwingOnly,
              onSelected: (v) => setState(() => _showOwingOnly = v),
              selectedColor: Colors.red.shade100,
              labelStyle: TextStyle(
                color:
                    _showOwingOnly ? Colors.red.shade700 : Colors.grey.shade700,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: customers.isEmpty
              ? _Empty(
                  onAdd: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerFormScreen())))
              : filtered.isEmpty
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                          _showOwingOnly
                              ? 'No customers with outstanding balance'
                              : 'No customers match your search',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500)),
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final owing =
                            sales.totalOwingForCustomer(filtered[i].id);
                        return _CustomerTile(
                          customer: filtered[i],
                          owing: owing,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CustomerDetailScreen(
                                      customerId: filtered[i].id))),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}

// ---- Customer Tile ----
class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final double owing;
  final VoidCallback onTap;
  const _CustomerTile({
    required this.customer,
    required this.owing,
    required this.onTap,
  });

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
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
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
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis),
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
    if (customer == null) {
      return const Scaffold(body: Center(child: Text('Customer not found')));
    }

    final sales = context.watch<SaleProvider>().forCustomer(customerId);
    final owing =
        context.read<SaleProvider>().totalOwingForCustomer(customerId);
    final income = sales.fold(0.0, (s, e) => s + e.totalEggIncome);

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name, overflow: TextOverflow.ellipsis),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Customer',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CustomerFormScreen(existing: customer))),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Customer',
            onPressed: () => _confirmDelete(context, customer, owing),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Summary card
        Card(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(customer.phone, overflow: TextOverflow.ellipsis)),
            ]),
            if (customer.address != null && customer.address!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(customer.address!,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ],
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(children: [
                Expanded(
                    child: _StatBox('Total Sales', formatMoney(income),
                        Colors.grey.shade700)),
                VerticalDivider(color: Colors.grey.shade200),
                Expanded(
                    child: _StatBox(
                        'Outstanding',
                        formatMoney(owing),
                        owing > 0
                            ? Colors.red.shade600
                            : Colors.green.shade700)),
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: owing > 0 ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                          owing > 0 ? 'Outstanding Balance' : '✓ Fully Settled',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text(formatMoney(owing),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: owing > 0
                              ? Colors.red.shade700
                              : Colors.green.shade700)),
                ],
              ),
            ),
            if (owing > 0) ...[
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markAllPaid(context, sales),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Mark All as Paid'),
                  )),
            ],
          ]),
        )),
        const SizedBox(height: 20),

        // Sale history header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Sale History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('${sales.length} sales',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ]),
        const SizedBox(height: 8),

        if (sales.isEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: Text('No sales recorded yet',
                      style: TextStyle(color: Colors.grey.shade500))))
        else
          ...sales.map((s) => _SaleTile(sale: s)),

        const SizedBox(height: 80),
      ]),
    );
  }

  /// Confirm and delete the customer (and warn if they have sales history)
  void _confirmDelete(BuildContext context, Customer customer, double owing) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${customer.name}?'),
            if (owing > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This customer owes ${formatMoney(owing)}. '
                      'Their sales history will remain but they will be removed from the customer list.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.red.shade700),
                    ),
                  ),
                ]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<CustomerProvider>().delete(customer.id);
              if (context.mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${customer.name} deleted')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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

class _SaleTile extends StatelessWidget {
  final Sale sale;
  const _SaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final isPaid = sale.amountOwed <= 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor:
              isPaid ? Colors.green.shade50 : Colors.orange.shade50,
          child: Icon(
            isPaid ? Icons.check : Icons.pending_outlined,
            size: 14,
            color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
          ),
        ),
        title: Text(formatDate(sale.date),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(
          '${sale.crates} crates · ₦${sale.pricePerCrate.toStringAsFixed(0)}/crate',
          style: const TextStyle(fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatMoney(sale.totalEggIncome),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            if (!isPaid)
              Text('Owes ${formatMoney(sale.amountOwed)}',
                  style: TextStyle(fontSize: 10, color: Colors.red.shade500),
                  overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
      ]);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('No customers yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Add customers to track egg sales and payments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
}

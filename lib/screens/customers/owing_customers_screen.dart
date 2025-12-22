import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/customer.dart';
import '../../utils/currency.dart';
import 'customer_details_screen.dart';

class OwingCustomersScreen extends StatefulWidget {
  final TransactionController txController;

  const OwingCustomersScreen({super.key, required this.txController});

  @override
  State<OwingCustomersScreen> createState() => _OwingCustomersScreenState();
}

class _OwingCustomersScreenState extends State<OwingCustomersScreen> {
  @override
  Widget build(BuildContext context) {
    final owingCustomers =
        widget.txController.customers.where((c) => c.owing > 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Customers Owing')),
      body: owingCustomers.isEmpty
          ? const Center(child: Text('No customers are owing'))
          : ListView.builder(
              itemCount: owingCustomers.length,
              itemBuilder: (_, i) {
                final c = owingCustomers[i];
                return Card(
                  child: ListTile(
                    title: Text(c.name),
                    subtitle: Text('Owes ${formatMoney(c.owing)}'),
                    leading: Checkbox(
                      value: false,
                      onChanged: (_) => _confirmPayment(context, c),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerDetailsScreen(
                            customer: c,
                            txController: widget.txController,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
    );
  }

  void _confirmPayment(BuildContext context, Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Mark ${customer.name} as fully paid?\n'
          'Amount: ${formatMoney(customer.owing)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      widget.txController.recordFullPayment(customer);
      setState(() {});
    }
  }
}

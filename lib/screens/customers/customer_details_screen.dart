import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/customer.dart';
import '../../models/customer_transaction.dart';
import '../../utils/currency.dart';
import '../../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'add_customer_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;
  final TransactionController txController;

  const CustomerDetailsScreen({
    Key? key,
    required this.customer,
    required this.txController,
  }) : super(key: key);

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  late Customer _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  void _editCustomer() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(customer: _customer),
      ),
    );

    if (updated is Customer) {
      widget.txController.updateCustomer(updated);
      setState(() {
        _customer = updated;
      });
    }
  }

  void _addTransaction() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(customerId: _customer.id),
      ),
    );

    if (res is CustomerTransaction) {
      setState(() {
        widget.txController.addTransaction(res);
        _customer =
            widget.txController.customersBox.get(_customer.id) ?? _customer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final txs = widget.txController.forCustomer(_customer.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(_customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCustomer,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${_customer.phone}'),
                    Text('Address: ${_customer.address ?? '-'}'),
                    Text('Total Spent: ${formatMoney(_customer.totalSpent)}'),
                    Text('Total Paid: ${formatMoney(_customer.totalPaid)}'),
                    Text('Balance: ${formatMoney(_customer.balance)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transactions',
                    style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton(
                  onPressed: _addTransaction,
                  child: const Text('Add Transaction'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: txs.isEmpty
                  ? const Center(child: Text('No transactions yet'))
                  : ListView.builder(
                      itemCount: txs.length,
                      itemBuilder: (_, i) => TransactionTile(tx: txs[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

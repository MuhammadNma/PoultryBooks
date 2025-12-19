import 'package:flutter/material.dart';
import 'package:poultry_profit_calculator/models/customer_transaction.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/customer.dart';
import '../../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

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
  void _addTransaction() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(customerId: widget.customer.id),
      ),
    );

    if (res is CustomerTransaction) {
      setState(() {
        // Only pass the transaction; controller updates customer totals internally
        widget.txController.addTransaction(res);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final txs = widget.txController.forCustomer(widget.customer.id);

    return Scaffold(
      appBar: AppBar(title: Text(widget.customer.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${widget.customer.phone}'),
                    const SizedBox(height: 6),
                    Text('Address: ${widget.customer.address ?? '-'}'),
                    const SizedBox(height: 6),
                    Text(
                        'Total Spent: ₦${widget.customer.totalSpent.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    Text(
                        'Total Paid: ₦${widget.customer.totalPaid.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    Text(
                        'Balance: ₦${widget.customer.balance.toStringAsFixed(2)}'),
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
                      itemBuilder: (context, index) =>
                          TransactionTile(tx: txs[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

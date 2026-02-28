// import 'package:flutter/material.dart';
// import '../../controllers/transaction_controller.dart';
// import '../../models/customer.dart';
// import '../../models/customer_transaction.dart';
// import '../../utils/currency.dart';
// import '../../widgets/transaction_tile.dart';
// import 'add_transaction_screen.dart';
// import 'add_customer_screen.dart';

// class CustomerDetailsScreen extends StatefulWidget {
//   final Customer customer;
//   final TransactionController txController;

//   const CustomerDetailsScreen({
//     Key? key,
//     required this.customer,
//     required this.txController,
//   }) : super(key: key);

//   @override
//   State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
// }

// class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
//   late Customer _customer;

//   @override
//   void initState() {
//     super.initState();
//     _refreshCustomer();
//   }

//   void _refreshCustomer() {
//     _customer = widget.txController.customersBox.get(widget.customer.id) ??
//         widget.customer;
//   }

//   Future<void> _editCustomer() async {
//     final updated = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddCustomerScreen(customer: _customer),
//       ),
//     );

//     if (updated is Customer) {
//       widget.txController.updateCustomer(updated);
//       setState(() => _refreshCustomer());
//     }
//   }

//   Future<void> _addTransaction() async {
//     final res = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddTransactionScreen(customerId: _customer.id),
//       ),
//     );

//     if (res is CustomerTransaction) {
//       widget.txController.addTransaction(res);
//       setState(() => _refreshCustomer());
//     }
//   }

//   void _deleteTransaction(CustomerTransaction tx) {
//     widget.txController.deleteTransaction(tx);
//     setState(() => _refreshCustomer());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final txs = widget.txController.forCustomer(_customer.id)
//       ..sort((a, b) => b.date.compareTo(a.date));

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_customer.name),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: _editCustomer,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// CUSTOMER SUMMARY
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Phone: ${_customer.phone}'),
//                     Text('Address: ${_customer.address ?? '-'}'),
//                     const Divider(),
//                     Text('Total Bought: ${formatMoney(_customer.totalSpent)}'),
//                     Text('Total Paid: ${formatMoney(_customer.totalPaid)}'),
//                     Text(
//                       'Owing: ${formatMoney(_customer.owing)}',
//                       style: TextStyle(
//                         color: _customer.owing > 0 ? Colors.red : Colors.green,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             /// TRANSACTIONS HEADER
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Transactions',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 ElevatedButton(
//                   onPressed: _addTransaction,
//                   child: const Text('Add Transaction'),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             /// TRANSACTIONS LIST
//             Expanded(
//               child: txs.isEmpty
//                   ? const Center(child: Text('No transactions yet'))
//                   : ListView.builder(
//                       itemCount: txs.length,
//                       itemBuilder: (_, i) {
//                         final tx = txs[i];
//                         return TransactionTile(
//                           tx: tx,
//                           onDelete: () => _deleteTransaction(tx),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
    _refreshCustomer();
  }

  void _refreshCustomer() {
    _customer = widget.txController.customersBox.get(widget.customer.id) ??
        widget.customer;
  }

  Future<void> _editCustomer() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(customer: _customer),
      ),
    );

    if (updated is Customer) {
      widget.txController.updateCustomer(updated);
      setState(() => _refreshCustomer());
    }
  }

  Future<void> _addTransaction() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(customerId: _customer.id),
      ),
    );

    if (res is CustomerTransaction) {
      widget.txController.addTransaction(res);
      setState(() => _refreshCustomer());
    }
  }

  void _deleteTransaction(CustomerTransaction tx) {
    widget.txController.deleteTransaction(tx);
    setState(() => _refreshCustomer());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final txs = widget.txController.forCustomer(_customer.id)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        icon: const Icon(Icons.add),
        label: const Text("Add Transaction"),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /// 🔹 Modern Header
            SliverAppBar(
              pinned: true,
              expandedHeight: 140,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  _customer.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _editCustomer,
                )
              ],
            ),

            /// 🔹 Customer Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Contact Info
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(_customer.phone),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_customer.address ?? "No address"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      /// Totals
                      _infoRow(
                          "Total Bought", formatMoney(_customer.totalSpent)),
                      const SizedBox(height: 8),
                      _infoRow("Total Paid", formatMoney(_customer.totalPaid)),
                      const SizedBox(height: 12),

                      /// Owing Highlight
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _customer.owing > 0
                              ? Colors.red.withOpacity(0.08)
                              : Colors.green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Outstanding Balance",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              formatMoney(_customer.owing),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _customer.owing > 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔹 Transactions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  "Transactions",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            /// 🔹 Transactions List
            if (txs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    "No transactions yet",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final tx = txs[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: TransactionTile(
                                tx: tx,
                                onDelete: () => _deleteTransaction(tx),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: txs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

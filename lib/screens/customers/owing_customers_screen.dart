// import 'package:flutter/material.dart';
// import '../../controllers/transaction_controller.dart';
// import '../../models/customer.dart';
// import '../../utils/currency.dart';
// import 'customer_details_screen.dart';

// class OwingCustomersScreen extends StatefulWidget {
//   final TransactionController txController;

//   const OwingCustomersScreen({super.key, required this.txController});

//   @override
//   State<OwingCustomersScreen> createState() => _OwingCustomersScreenState();
// }

// class _OwingCustomersScreenState extends State<OwingCustomersScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final owingCustomers =
//         widget.txController.customers.where((c) => c.owing > 0).toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Customers Owing')),
//       body: owingCustomers.isEmpty
//           ? const Center(child: Text('No customers are owing'))
//           : ListView.builder(
//               itemCount: owingCustomers.length,
//               itemBuilder: (_, i) {
//                 final c = owingCustomers[i];
//                 return Card(
//                   child: ListTile(
//                     title: Text(c.name),
//                     subtitle: Text('Owes ${formatMoney(c.owing)}'),
//                     leading: Checkbox(
//                       value: false,
//                       onChanged: (_) => _confirmPayment(context, c),
//                     ),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CustomerDetailsScreen(
//                             customer: c,
//                             txController: widget.txController,
//                           ),
//                         ),
//                       ).then((_) => setState(() {}));
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   void _confirmPayment(BuildContext context, Customer customer) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Confirm Payment'),
//         content: Text(
//           'Mark ${customer.name} as fully paid?\n'
//           'Amount: ${formatMoney(customer.owing)}',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       widget.txController.recordFullPayment(customer);
//       setState(() {});
//     }
//   }
// }

import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/customer.dart';
import '../../utils/currency.dart';
import 'customer_details_screen.dart';

class OwingCustomersScreen extends StatefulWidget {
  final TransactionController txController;

  const OwingCustomersScreen({
    super.key,
    required this.txController,
  });

  @override
  State<OwingCustomersScreen> createState() => _OwingCustomersScreenState();
}

class _OwingCustomersScreenState extends State<OwingCustomersScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final owingCustomers =
        widget.txController.customers.where((c) => c.owing > 0).toList();

    final totalOwing =
        owingCustomers.fold<double>(0, (sum, c) => sum + c.owing);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers Owing'),
        centerTitle: true,
      ),
      body: owingCustomers.isEmpty
          ? _buildEmptyState(theme)
          : Column(
              children: [
                /// SUMMARY CARD
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _SummaryCard(
                    totalCustomers: owingCustomers.length,
                    totalOwing: totalOwing,
                  ),
                ),

                /// LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: owingCustomers.length,
                    itemBuilder: (_, i) {
                      final c = owingCustomers[i];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CustomerOwingCard(
                          customer: c,
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
                          onMarkPaid: () => _confirmPayment(context, c),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 70,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'All customers are settled 🎉',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'No outstanding payments at the moment.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPayment(BuildContext context, Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Confirm Full Payment'),
        content: Text(
          'Mark ${customer.name} as fully paid?\n\n'
          'Amount: ${formatMoney(customer.owing)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
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

/// SUMMARY CARD
class _SummaryCard extends StatelessWidget {
  final int totalCustomers;
  final double totalOwing;

  const _SummaryCard({
    required this.totalCustomers,
    required this.totalOwing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outstanding Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoTile(
                  label: 'Customers',
                  value: totalCustomers.toString(),
                ),
                _InfoTile(
                  label: 'Total Owing',
                  value: formatMoney(totalOwing),
                  highlight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}

/// CUSTOMER CARD
class _CustomerOwingCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onMarkPaid;

  const _CustomerOwingCard({
    required this.customer,
    required this.onTap,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Owes ${formatMoney(customer.owing)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onMarkPaid,
                child: const Text('Mark Paid'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';

class CustomerSummaryTiles extends StatelessWidget {
  final TransactionController txController;

  const CustomerSummaryTiles({
    Key? key,
    required this.txController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customers = txController.customers;

    final totalCustomers = customers.length;
    final totalBought =
        customers.fold<double>(0.0, (sum, c) => sum + c.totalSpent);
    final totalPaid =
        customers.fold<double>(0.0, (sum, c) => sum + c.totalPaid);
    final totalOwing = customers.fold<double>(
      0.0,
      (sum, c) => sum + (c.balance < 0 ? c.balance.abs() : 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Summary", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(
              title: "Customers",
              value: totalCustomers.toString(),
              icon: Icons.people,
            ),
            const SizedBox(width: 12),
            _statCard(
              title: "Total Bought",
              value: "₦${totalBought.toStringAsFixed(2)}",
              icon: Icons.shopping_cart,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(
              title: "Total Paid",
              value: "₦${totalPaid.toStringAsFixed(2)}",
              icon: Icons.payments,
            ),
            const SizedBox(width: 12),
            _statCard(
              title: "Total Owing",
              value: "₦${totalOwing.toStringAsFixed(2)}",
              icon: Icons.warning_amber,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 6),
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

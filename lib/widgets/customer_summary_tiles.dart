// import 'package:flutter/material.dart';
// import '../../controllers/transaction_controller.dart';
// import '../../utils/currency.dart';
// import '../../screens/customers/owing_customers_screen.dart';

// class CustomerSummaryTiles extends StatelessWidget {
//   final TransactionController txController;

//   const CustomerSummaryTiles({
//     Key? key,
//     required this.txController,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final customers = txController.customers;

//     final totalCustomers = customers.length;
//     final totalBought = customers.fold<double>(
//       0.0,
//       (sum, c) => sum + c.totalSpent,
//     );

//     final totalPaid = customers.fold<double>(
//       0.0,
//       (sum, c) => sum + c.totalPaid,
//     );

//     final totalOwing = customers.fold<double>(
//       0.0,
//       (sum, c) => sum + c.owing,
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Summary", style: Theme.of(context).textTheme.titleLarge),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             _statCard(
//               title: "Customers",
//               value: totalCustomers.toString(),
//               icon: Icons.people,
//             ),
//             const SizedBox(width: 12),
//             _statCard(
//               title: "Total Bought",
//               value: formatMoney(totalBought),
//               icon: Icons.shopping_cart,
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             _statCard(
//               title: "Total Paid",
//               value: formatMoney(totalPaid),
//               icon: Icons.payments,
//             ),
//             const SizedBox(width: 12),
//             _statCard(
//               title: "Total Owing",
//               value: formatMoney(totalOwing),
//               icon: Icons.warning_amber,
//               onTap: totalOwing > 0
//                   ? () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => OwingCustomersScreen(
//                             txController: txController,
//                           ),
//                         ),
//                       );
//                     }
//                   : null,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _statCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     VoidCallback? onTap,
//   }) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.blue.shade100),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(icon, color: Colors.blue),
//               const SizedBox(height: 6),
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 14, fontWeight: FontWeight.w500)),
//               const SizedBox(height: 4),
//               Text(value,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';
import '../../utils/currency.dart';
import '../../screens/customers/owing_customers_screen.dart';

class CustomerSummaryTiles extends StatelessWidget {
  final TransactionController txController;

  const CustomerSummaryTiles({
    super.key,
    required this.txController,
  });

  @override
  Widget build(BuildContext context) {
    final customers = txController.customers;

    final totalCustomers = customers.length;
    final totalBought =
        customers.fold<double>(0.0, (sum, c) => sum + c.totalSpent);
    final totalPaid =
        customers.fold<double>(0.0, (sum, c) => sum + c.totalPaid);
    final totalOwing = customers.fold<double>(0.0, (sum, c) => sum + c.owing);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Overview",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _mediumCard(
              context,
              title: "Customers",
              value: totalCustomers.toString(),
              icon: Icons.group_outlined,
              color: Colors.blue,
            ),
            const SizedBox(width: 14),
            _mediumCard(
              context,
              title: "Bought",
              value: formatMoney(totalBought),
              icon: Icons.shopping_cart_outlined,
              color: Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _mediumCard(
              context,
              title: "Paid",
              value: formatMoney(totalPaid),
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(width: 14),
            _mediumCard(
              context,
              title: "Owing",
              value: formatMoney(totalOwing),
              icon: Icons.warning_amber_rounded,
              color: totalOwing > 0 ? Colors.red : Colors.grey,
              onTap: totalOwing > 0
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OwingCustomersScreen(
                            txController: txController,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _mediumCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top row (icon)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),

              const SizedBox(height: 18),

              /// Value
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              /// Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

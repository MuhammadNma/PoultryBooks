// import 'package:flutter/material.dart';

// class ResultCard extends StatelessWidget {
//   final double eggIncome;
//   final double feedCost;
//   final double fixedCostPerDay;
//   final double profit;

//   const ResultCard({
//     Key? key,
//     required this.eggIncome,
//     required this.feedCost,
//     required this.fixedCostPerDay,
//     required this.profit,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Egg Income: ₦${eggIncome.toStringAsFixed(2)}'),
//             Text('Feed Cost: ₦${feedCost.toStringAsFixed(2)}'),
//             Text('Fixed Cost: ₦${fixedCostPerDay.toStringAsFixed(2)}'),
//             const SizedBox(height: 6),
//             Text(
//               'Profit: ₦${profit.toStringAsFixed(2)}',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultCard extends StatelessWidget {
  final double eggIncome;
  final double feedCost;
  final double fixedCostPerDay;
  final double profit;

  const ResultCard({
    Key? key,
    required this.eggIncome,
    required this.feedCost,
    required this.fixedCostPerDay,
    required this.profit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_NG', symbol: '₦');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Egg Income: ${currencyFormatter.format(eggIncome)}'),
            Text('Feed Cost: ${currencyFormatter.format(feedCost)}'),
            Text('Fixed Cost: ${currencyFormatter.format(fixedCostPerDay)}'),
            const SizedBox(height: 6),
            Text(
              'Profit: ${currencyFormatter.format(profit)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

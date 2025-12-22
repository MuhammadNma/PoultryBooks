import 'package:flutter/material.dart';
import 'package:poultry_profit_calculator/models/customer_transaction.dart';
import '../../utils/currency.dart';

// class TransactionTile extends StatelessWidget {
//   final CustomerTransaction tx;

//   const TransactionTile({Key? key, required this.tx}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
//       child: ListTile(
//         title: Text('${tx.crates} crates + ${tx.pieces} pieces'),
//         subtitle: Text(
//           'Total: ${formatMoney(tx.totalAmount)} | Paid: ${formatMoney(tx.amountPaid)}',
//         ),
//         trailing: Text(
//           '${tx.date.toLocal().toString().split(' ')[0]}',
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//       ),
//     );
//   }
// }

class TransactionTile extends StatelessWidget {
  final CustomerTransaction tx;
  final VoidCallback? onDelete;

  const TransactionTile({
    Key? key,
    required this.tx,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tile = Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text('${tx.crates} crates + ${tx.pieces} pieces'),
        subtitle: Text(
          'Total: ₦${tx.totalAmount.toStringAsFixed(2)} | Paid: ₦${tx.amountPaid.toStringAsFixed(2)}',
        ),
        trailing: Text(
          tx.date.toLocal().toString().split(' ')[0],
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );

    // If no delete handler, return normal tile
    if (onDelete == null) return tile;

    // Otherwise wrap with Dismissible
    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Transaction?'),
            content: const Text(
              'This will remove the transaction and update customer totals.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete!(),
      child: tile,
    );
  }
}

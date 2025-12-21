import 'package:flutter/material.dart';
import 'package:poultry_profit_calculator/models/customer_transaction.dart';
import '../../utils/currency.dart';

class TransactionTile extends StatelessWidget {
  final CustomerTransaction tx;

  const TransactionTile({Key? key, required this.tx}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: ListTile(
        title: Text('${tx.crates} crates + ${tx.pieces} pieces'),
        subtitle: Text(
          'Total: ${formatMoney(tx.totalAmount)} | Paid: ${formatMoney(tx.amountPaid)}',
        ),
        trailing: Text(
          '${tx.date.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}

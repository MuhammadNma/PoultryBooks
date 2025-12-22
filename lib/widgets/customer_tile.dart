import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../utils/currency.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const CustomerTile({
    Key? key,
    required this.customer,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final owing = customer.owing;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(customer.phone),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              owing > 0 ? 'Owing ${formatMoney(owing)}' : 'Clear',
              style: TextStyle(
                color: owing > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Paid: ${formatMoney(customer.totalPaid)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

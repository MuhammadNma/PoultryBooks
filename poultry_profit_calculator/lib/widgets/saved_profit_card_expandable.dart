import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/profit_record.dart';
import '../controllers/profit_controller.dart';

class SavedProfitCardExpandable extends StatefulWidget {
  final ProfitRecord record;
  final ProfitController profitController; // pass controller to delete
  final VoidCallback onDeleted; // callback to update list

  const SavedProfitCardExpandable({
    super.key,
    required this.record,
    required this.profitController,
    required this.onDeleted,
  });

  @override
  State<SavedProfitCardExpandable> createState() =>
      _SavedProfitCardExpandableState();
}

class _SavedProfitCardExpandableState extends State<SavedProfitCardExpandable> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    final dateFormatter = DateFormat('EEEE, dd/MM/yyyy');
    final totalCost = widget.record.feedCost + widget.record.fixedCostPerDay;
    final profitColor = widget.record.profit >= 0 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (val) {
          setState(() {
            _isExpanded = val;
          });
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormatter.format(widget.record.date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Profit: ${currencyFormatter.format(widget.record.profit)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: profitColor,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Egg Income: ${currencyFormatter.format(widget.record.eggIncome)}'),
                Text(
                    'Feed Cost: ${currencyFormatter.format(widget.record.feedCost)}'),
                Text(
                    'Fixed Cost: ${currencyFormatter.format(widget.record.fixedCostPerDay)}'),
                const Divider(),
                Text(
                  'Total Cost: ${currencyFormatter.format(totalCost)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (_isExpanded)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await widget.profitController
                            .deleteRecord(widget.record);
                        widget.onDeleted(); // refresh the list in UI
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

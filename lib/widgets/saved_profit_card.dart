import 'package:flutter/material.dart';
import '../models/profit_record.dart';
import '../controllers/profit_controller.dart';
import '../utils/formatters.dart';

class SavedProfitCardExpandable extends StatefulWidget {
  final ProfitRecord record;
  final ProfitController controller;
  final VoidCallback onDeleted;

  const SavedProfitCardExpandable({
    super.key,
    required this.record,
    required this.controller,
    required this.onDeleted,
  });

  @override
  State<SavedProfitCardExpandable> createState() =>
      _SavedProfitCardExpandableState();
}

class _SavedProfitCardExpandableState extends State<SavedProfitCardExpandable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final totalCost = widget.record.feedCost + widget.record.fixedCostPerDay;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        onExpansionChanged: (v) {
          setState(() => _expanded = v);
        },
        title: Text(
          formatDateWithDay(widget.record.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Profit: ${formatNaira(widget.record.profit)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Egg Income: ${formatNaira(widget.record.eggIncome)}'),
                Text('Feed Cost: ${formatNaira(widget.record.feedCost)}'),
                Text(
                    'Fixed Cost: ${formatNaira(widget.record.fixedCostPerDay)}'),
                const Divider(),
                Text(
                  'Total Cost: ${formatNaira(totalCost)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_expanded)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await widget.controller
                            .deleteByDate(widget.record.date);
                        widget.onDeleted();
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

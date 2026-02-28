import 'package:flutter/material.dart';
import '../models/profit_record.dart';
import 'package:intl/intl.dart';

class SavedRecordsList extends StatelessWidget {
  final List<ProfitRecord> records;
  const SavedRecordsList({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 10),
        Text('Saved Records', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final rec = records[index];
            final dateStr = DateFormat('dd/MM/yyyy').format(rec.date);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Egg Income: ${rec.eggIncome.toStringAsFixed(2)} | Feed: ${rec.feedCost.toStringAsFixed(2)} | Fixed: ${rec.fixedCostPerDay.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profit: ${rec.profit.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

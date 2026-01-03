import 'package:flutter/material.dart';
import '../models/profit_record.dart';
import '../utils/format.dart';

class HistoryList extends StatelessWidget {
  final List<ProfitRecord> records;

  const HistoryList({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child:
            Text('No saved records yet. Tap "Save Record" after calculating.'),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: records.length,
        itemBuilder: (context, index) {
          final r = records[index];
          return ListTile(
            leading: CircleAvatar(child: Text((index + 1).toString())),
            title: Text(money(r.profit)),
            subtitle: Text(r.date.toLocal().toString().split('.').first),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Details'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profit: ${money(r.profit)}'),
                        Text('Egg Income: ${money(r.eggIncome)}'),
                        Text('Feed Cost: ${money(r.feedCost)}'),
                        Text('Fixed Cost/day: ${money(r.fixedCostPerDay)}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

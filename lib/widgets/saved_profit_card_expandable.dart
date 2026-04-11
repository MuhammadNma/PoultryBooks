import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/profit_record.dart';
import '../controllers/profit_controller.dart';

class SavedProfitCardExpandable extends StatelessWidget {
  final ProfitRecord record;
  final ProfitController profitController;
  final VoidCallback onDeleted;

  final bool isExpanded;
  final VoidCallback onTap;

  const SavedProfitCardExpandable({
    super.key,
    required this.record,
    required this.profitController,
    required this.onDeleted,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    final date = DateFormat('EEE, dd MMM yyyy').format(record.date);

    final totalCost = record.feedCost + record.fixedCostPerDay;
    final profitColor = record.profit >= 0 ? Colors.green : Colors.red;

    final profitLabel = record.profit >= 0 ? "Profit" : "Loss";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: isExpanded ? 12 : 6,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// PROFIT ROW + BADGE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(profitLabel),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: profitColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          record.profit >= 0 ? "Gain" : "Loss",
                          style: TextStyle(
                            fontSize: 11,
                            color: profitColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currency.format(record.profit),
                    style: TextStyle(
                      color: profitColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              /// QUICK STATS (VISIBLE EVEN WHEN COLLAPSED)
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat("Eggs", record.eggsProduced.toString()),
                  _miniStat("Feed", "${record.feedCost.toStringAsFixed(0)} ₦"),
                ],
              ),

              /// EXPANDED CONTENT
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  children: [
                    const Divider(height: 20),
                    _row("Eggs Laid", "${record.eggsProduced}"),
                    _row(
                      "Feed Eaten",
                      "${(record.feedEatenKg ?? 0).toStringAsFixed(1)} kg",
                    ), // ✅ new
                    _row("Egg Income", currency.format(record.eggIncome)),
                    _row("Feed Cost", currency.format(record.feedCost)),
                    _row("Fixed Cost", currency.format(record.fixedCostPerDay)),
                    const Divider(),
                    _row("Total Cost", currency.format(totalCost), bold: true),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await profitController.deleteRecord(record);
                          onDeleted();
                        },
                      ),
                    ),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

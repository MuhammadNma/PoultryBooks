// import 'package:flutter/material.dart';
// import '../../controllers/profit_controller.dart';
// import '../../utils/chart_utils.dart';
// import '../../widgets/simple_bar_chart.dart';

// class DashboardCharts extends StatelessWidget {
//   final ProfitController controller;

//   const DashboardCharts({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final recent = ChartUtils.currentWeekRecords(controller.records);

//     final labels = ChartUtils.weekdayLabels();

//     return Column(
//       children: [
//         SimpleBarChart(
//           title: 'Daily / Weekly Profit',
//           values: ChartUtils.profitByWeekday(recent),
//           xLabels: labels,
//           color: Colors.green,
//           showNaira: true,
//           yAxisTitle: 'Amount',
//         ),
//         SimpleBarChart(
//           title: 'Daily /Weekly Egg Production',
//           values: ChartUtils.eggProductionByWeekday(recent),
//           xLabels: labels,
//           color: Colors.orange,
//           yAxisTitle: 'Eggs Produced',
//         ),
//         // SimpleBarChart(
//         //   title: 'Egg Sales',
//         //   values: ChartUtils.eggSalesByWeekday(recent),
//         //   xLabels: labels,
//         //   color: Colors.blue,
//         //   showNaira: true,
//         //   yAxisTitle: 'Amount',
//         // ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../controllers/profit_controller.dart';
import '../../utils/chart_utils.dart';
import '../../widgets/simple_bar_chart.dart';

class DashboardCharts extends StatefulWidget {
  final ProfitController controller;

  const DashboardCharts({super.key, required this.controller});

  @override
  State<DashboardCharts> createState() => _DashboardChartsState();
}

class _DashboardChartsState extends State<DashboardCharts> {
  int _profitWeek = 0;
  int _productionWeek = 0;
  // int _salesWeek = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _chartSection(
          title: 'Daily / Weekly Profit',
          weekOffset: _profitWeek,
          onChanged: (val) => setState(() => _profitWeek = val),
          values: ChartUtils.profitByWeekday(
            ChartUtils.recordsForWeek(
              widget.controller.records,
              _profitWeek,
            ),
          ),
          color: Colors.green,
          showNaira: true,
          yAxisTitle: 'Amount',
        ),
        _chartSection(
          title: 'Daily / Weekly Egg Production',
          weekOffset: _productionWeek,
          onChanged: (val) => setState(() => _productionWeek = val),
          values: ChartUtils.eggProductionByWeekday(
            ChartUtils.recordsForWeek(
              widget.controller.records,
              _productionWeek,
            ),
          ),
          color: Colors.orange,
          yAxisTitle: 'Eggs Produced',
        ),
        // _chartSection(
        //   title: 'Egg Sales',
        //   weekOffset: _salesWeek,
        //   onChanged: (val) => setState(() => _salesWeek = val),
        //   values: ChartUtils.eggSalesByWeekday(
        //     ChartUtils.recordsForWeek(
        //       widget.controller.records,
        //       _salesWeek,
        //     ),
        //   ),
        //   color: Colors.blue,
        //   showNaira: true,
        //   yAxisTitle: 'Amount',
        // ),
      ],
    );
  }

  /* ============================================================
     CHART SECTION WITH DROPDOWN
     ============================================================ */

  Widget _chartSection({
    required String title,
    required int weekOffset,
    required Function(int) onChanged,
    required List<double> values,
    required Color color,
    required String yAxisTitle,
    bool showNaira = false,
  }) {
    final labels = ChartUtils.weekdayLabels();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'View Week',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              /// Modern Selector Button
              GestureDetector(
                onTap: () => _showWeekPicker(weekOffset, onChanged),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Text(
                        ChartUtils.weekLabel(weekOffset),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SimpleBarChart(
          title: title,
          values: values,
          xLabels: labels,
          color: color,
          showNaira: showNaira,
          yAxisTitle: yAxisTitle,
        ),
      ],
    );
  }

  void _showWeekPicker(
    int currentOffset,
    Function(int) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Week',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 20, // last 20 weeks
                  itemBuilder: (context, index) {
                    final offset = -index;
                    final isSelected = offset == currentOffset;

                    return ListTile(
                      title: Text(
                        ChartUtils.weekLabel(offset),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        onChanged(offset);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

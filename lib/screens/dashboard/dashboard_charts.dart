import 'package:flutter/material.dart';
import '../../controllers/profit_controller.dart';
import '../../utils/chart_utils.dart';
import '../../widgets/simple_bar_chart.dart';

class DashboardCharts extends StatelessWidget {
  final ProfitController controller;

  const DashboardCharts({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final records = controller.records;
    final days = ChartUtils.lastNDays(7);

    final labels = days.map((d) => '${d.day}/${d.month}').toList();

    final profitData =
        days.map((d) => ChartUtils.profitForDay(d, records)).toList();

    final productionData =
        days.map((d) => ChartUtils.eggProductionForDay(d, records)).toList();

    final salesData =
        days.map((d) => ChartUtils.eggSalesForDay(d, records)).toList();

    return Column(
      children: [
        SimpleBarChart(
          title: 'Daily Profit',
          values: profitData,
          xLabels: labels,
          color: Colors.green,
        ),
        SimpleBarChart(
          title: 'Daily Egg Production',
          values: productionData,
          xLabels: labels,
          color: Colors.orange,
        ),
        SimpleBarChart(
          title: 'Egg Sales',
          values: salesData,
          xLabels: labels,
          color: Colors.blue,
        ),
      ],
    );
  }
}

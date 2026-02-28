import 'package:flutter/material.dart';
import '../../controllers/profit_controller.dart';
import '../../utils/chart_utils.dart';
import '../../widgets/simple_bar_chart.dart';

class DashboardCharts extends StatelessWidget {
  final ProfitController controller;

  const DashboardCharts({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final recent = ChartUtils.currentWeekRecords(controller.records);

    final labels = ChartUtils.weekdayLabels();

    return Column(
      children: [
        SimpleBarChart(
          title: 'Daily / Weekly Profit',
          values: ChartUtils.profitByWeekday(recent),
          xLabels: labels,
          color: Colors.green,
          showNaira: true,
          yAxisTitle: 'Amount',
        ),
        SimpleBarChart(
          title: 'Daily /Weekly Egg Production',
          values: ChartUtils.eggProductionByWeekday(recent),
          xLabels: labels,
          color: Colors.orange,
          yAxisTitle: 'Eggs Produced',
        ),
        // SimpleBarChart(
        //   title: 'Egg Sales',
        //   values: ChartUtils.eggSalesByWeekday(recent),
        //   xLabels: labels,
        //   color: Colors.blue,
        //   showNaira: true,
        //   yAxisTitle: 'Amount',
        // ),
      ],
    );
  }
}

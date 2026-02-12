import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> xLabels;
  final String title;
  final Color color;
  final bool showNaira;
  final String yAxisTitle;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.xLabels,
    required this.title,
    required this.color,
    this.showNaira = false,
    this.yAxisTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return _EmptyChart(title: title);
    }

    final maxValue = values.reduce(max);
    final maxY = _niceMaxY(maxValue);
    final interval = _niceInterval(maxY);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: _tooltipData(),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: _titles(interval),
                  barGroups: _bars(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- BARS ---------------- */

  List<BarChartGroupData> _bars() {
    return List.generate(
      values.length,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            color: color,
            width: 14,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }

  /* ---------------- AXIS ---------------- */

  FlTitlesData _titles(double interval) {
    return FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

      /// X AXIS (Weekdays)
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, _) {
            final i = value.toInt();
            if (i < 0 || i >= xLabels.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                xLabels[i],
                style: const TextStyle(fontSize: 11),
              ),
            );
          },
        ),
      ),

      /// Y AXIS (Values + Title)
      leftTitles: AxisTitles(
        axisNameWidget: yAxisTitle.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  yAxisTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        axisNameSize: 22,
        sideTitles: SideTitles(
          showTitles: true,
          interval: interval,
          reservedSize: 56,
          getTitlesWidget: (value, _) {
            final v = value.toInt();
            return Text(
              showNaira ? '₦$v' : v.toString(),
              style: const TextStyle(fontSize: 11),
            );
          },
        ),
      ),
    );
  }

  /* ---------------- TOOLTIP ---------------- */

  BarTouchData _tooltipData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => Colors.black87,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final v = rod.toY.toInt();
          return BarTooltipItem(
            showNaira ? '₦$v' : '$v',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  /* ---------------- HELPERS ---------------- */

  double _niceMaxY(double value) {
    if (value <= 0) return 10;
    return (value * 1.2).ceilToDouble();
  }

  double _niceInterval(double maxY) {
    final raw = maxY / 4;
    final magnitude = pow(10, log(raw) ~/ ln10);
    return (raw / magnitude).ceil() * magnitude.toDouble();
  }
}

/* ---------------- EMPTY STATE ---------------- */

class _EmptyChart extends StatelessWidget {
  final String title;

  const _EmptyChart({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '$title\nNo data yet',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

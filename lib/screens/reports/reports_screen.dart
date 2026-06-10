// lib/screens/reports/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _month = DateTime.now();

  void _prev() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _next() {
    final now = DateTime.now();
    if (_month.year == now.year && _month.month == now.month) return;
    setState(() => _month = DateTime(_month.year, _month.month + 1));
  }

  @override
  Widget build(BuildContext context) {
    final logs     = context.watch<DailyLogProvider>();
    final sales    = context.watch<SaleProvider>();
    final expenses = context.watch<ExpenseProvider>();

    final y = _month.year;
    final m = _month.month;
    final now = DateTime.now();
    final isCurrentMonth = y == now.year && m == now.month;

    final monthSales    = sales.forMonth(y, m);
    final monthExpenses = expenses.forMonth(y, m);
    final monthLogs     = logs.forMonth(y, m);

    final totalIncome   = sales.totalIncomeForMonth(y, m);
    final totalExpenses = expenses.totalForMonth(y, m);
    final netProfit     = totalIncome - totalExpenses;
    final expCats       = expenses.byCategory(y, m);
    final totalEggsCollected =
        monthLogs.fold(0, (s, l) => s + l.eggsCollected);
    final totalEggsSold = sales.totalEggsSoldInMonth(y, m);
    final totalMortality =
        monthLogs.fold(0, (s, l) => s + l.mortality);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Month selector
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          IconButton(onPressed: _prev,
              icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Text(formatMonthYear(_month),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            onPressed: isCurrentMonth ? null : _next,
            icon: Icon(Icons.chevron_right,
                color: isCurrentMonth ? Colors.grey.shade300 : null),
          ),
        ]),
        const SizedBox(height: 16),

        // P&L summary
        _SummaryCard(title: 'Profit & Loss', rows: [
          _Row('Total Income',
              formatMoney(totalIncome), Colors.green.shade700),
          _Row('Total Expenses',
              formatMoney(totalExpenses), Colors.red.shade500),
          _Row('Net Profit / Loss', formatMoney(netProfit),
              netProfit >= 0
                  ? Colors.green.shade700 : Colors.red,
              bold: true),
        ]),
        const SizedBox(height: 12),

        // Egg summary
        _SummaryCard(title: 'Egg Summary', rows: [
          _Row('Eggs Collected',
              formatEggs(totalEggsCollected), Colors.grey.shade700),
          _Row('Eggs Sold',
              formatEggs(totalEggsSold), Colors.grey.shade700),
          _Row('Eggs on Hand',
              formatEggs((totalEggsCollected - totalEggsSold)
                  .clamp(0, 999999)),
              Colors.orange.shade700),
          _Row('Mortality',
              '$totalMortality birds', Colors.red.shade400),
        ]),
        const SizedBox(height: 12),

        // Expense breakdown by category
        if (expCats.isNotEmpty) ...[
          _SummaryCard(
            title: 'Expense Breakdown',
            rows: expCats.entries
                .map((e) => _Row(e.key, formatMoney(e.value),
                    Colors.red.shade400))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Sales list
        if (monthSales.isNotEmpty) ...[
          const Text('Sales This Month',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...monthSales.map((s) => Card(child: ListTile(
            dense: true,
            title: Text(s.customerName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${formatDate(s.date)} · ${s.crates} crates',
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatMoney(s.totalEggIncome),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                if (s.amountOwed > 0)
                  Text('Owes ${formatMoney(s.amountOwed)}',
                      style: TextStyle(
                          fontSize: 10, color: Colors.red.shade500),
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ))),
          const SizedBox(height: 12),
        ],

        // Expenses list
        if (monthExpenses.isNotEmpty) ...[
          const Text('Expenses This Month',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...monthExpenses.map((e) => Card(child: ListTile(
            dense: true,
            title: Text(e.category,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text(
                '${formatDate(e.date)}'
                '${e.description != null ? ' · ${e.description}' : ''}',
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis),
            trailing: Text(formatMoney(e.amount),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                    fontSize: 13)),
          ))),
        ],

        if (monthSales.isEmpty &&
            monthExpenses.isEmpty &&
            monthLogs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text('No records for ${formatMonthYear(_month)}',
                  style: TextStyle(color: Colors.grey.shade500)),
            ),
          ),

        const SizedBox(height: 80),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<_Row> rows;
  const _SummaryCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 12),
      ...rows.map((r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(child: Text(r.label,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13),
              overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(r.value,
              style: TextStyle(
                  color: r.color,
                  fontWeight: r.bold
                      ? FontWeight.bold : FontWeight.w600,
                  fontSize: r.bold ? 15 : 13)),
        ]),
      )),
    ]),
  ));
}

class _Row {
  final String label, value;
  final Color color;
  final bool bold;
  const _Row(this.label, this.value, this.color, {this.bold = false});
}

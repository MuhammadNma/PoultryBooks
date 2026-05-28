// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/app_theme.dart';
import '../../utils/formatters.dart';
import '../expenses/expenses_screen.dart';
import '../reports/reports_screen.dart';
import '../flocks/flocks_screen.dart';
import '../sales/sales_screen.dart';
import '../customers/customers_screen.dart';
import '../main_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final logs = context.watch<DailyLogProvider>();
    final sales = context.watch<SaleProvider>();
    final expenses = context.watch<ExpenseProvider>();
    final flocks = context.watch<FlockProvider>();
    final settings = context.watch<SettingsProvider>().settings;

    final totalSold = sales.totalEggsSold();
    final eggsOnHand = logs.totalEggsOnHand(totalSold);
    final monthIncome = sales.totalIncomeForMonth(now.year, now.month);
    final monthExpenses = expenses.totalForMonth(now.year, now.month);
    final monthProfit = monthIncome - monthExpenses;
    final totalOwing = sales.totalOwingAllCustomers;
    final todayLogs = logs.all.where((l) => isSameDay(l.date, now)).toList();
    final todayEggs = todayLogs.fold(0, (s, l) => s + l.eggsCollected);
    final expCats = expenses.byCategory(now.year, now.month);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Header ----
            _Header(farmName: settings.farmName, now: now),
            const SizedBox(height: 20),

            // ---- KPI Cards ----
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                _KpiCard(
                  label: 'Eggs on Hand',
                  value: formatEggs(eggsOnHand),
                  icon: Icons.inventory_2_outlined,
                  color: Colors.orange.shade600,
                ),
                _KpiCard(
                  label: 'Month Income',
                  value: formatMoneyCompact(monthIncome),
                  icon: Icons.trending_up,
                  color: Colors.green.shade600,
                ),
                _KpiCard(
                  label: 'Month Expenses',
                  value: formatMoneyCompact(monthExpenses),
                  icon: Icons.trending_down,
                  color: Colors.red.shade400,
                ),
                _KpiCard(
                  label: 'Month Profit',
                  value: formatMoneyCompact(monthProfit),
                  icon: Icons.account_balance,
                  color: monthProfit >= 0 ? Colors.green.shade700 : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Quick Access ----
            const _SectionTitle('Quick Access'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _QuickAction(
                  icon: Icons.receipt_long_outlined,
                  label: 'Expenses',
                  color: Colors.red.shade400,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExpensesScreen())),
                ),
                _QuickAction(
                  icon: Icons.bar_chart_outlined,
                  label: 'Reports',
                  color: Colors.purple.shade400,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen())),
                ),
                _QuickAction(
                  icon: Icons.groups_outlined,
                  label: 'Flocks',
                  color: AppTheme.primary,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FlocksScreen())),
                ),
                _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'New Sale',
                  color: Colors.blue.shade500,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SaleFormScreen())),
                ),
                _QuickAction(
                  icon: Icons.payments_outlined,
                  label: 'Add Expense',
                  color: Colors.orange.shade600,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExpenseFormScreen())),
                ),
                _QuickAction(
                  icon: Icons.egg_alt_outlined,
                  label: 'Log Eggs',
                  color: Colors.teal.shade500,
                  onTap: () {
                    // Switch to Daily Log tab (index 1)
                    final shell =
                        context.findAncestorStateOfType<MainShellState>();
                    shell?.switchTab(1);
                  },
                ),
                _QuickAction(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Add Customer',
                  color: Colors.indigo.shade400,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerFormScreen())),
                ),
                _QuickAction(
                  icon: Icons.sync_outlined,
                  label: 'Sync Now',
                  color: Colors.grey.shade600,
                  onTap: () {
                    final shell =
                        context.findAncestorStateOfType<MainShellState>();
                    shell?.triggerSync();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Today's Collection ----
            const _SectionTitle("Today's Collection"),
            const SizedBox(height: 8),
            Card(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: todayLogs.isEmpty
                  ? Row(children: [
                      Icon(Icons.info_outline, color: Colors.grey.shade400),
                      const SizedBox(width: 10),
                      Text('No eggs logged today yet',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ])
                  : Column(children: [
                      ...flocks.active.map((flock) {
                        final eggs = todayLogs
                            .where((l) => l.flockId == flock.id)
                            .fold(0, (s, l) => s + l.eggsCollected);
                        if (eggs == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(flock.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Text(formatEggs(eggs),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total today',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                          Text(formatEggs(todayEggs),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ]),
            )),
            const SizedBox(height: 16),

            // ---- Outstanding Payments ----
            if (totalOwing > 0) ...[
              const _SectionTitle('Outstanding Payments'),
              const SizedBox(height: 8),
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text('Customers owe you',
                          style: TextStyle(color: Colors.grey.shade700))),
                  Text(formatMoney(totalOwing),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red.shade600)),
                ]),
              )),
              const SizedBox(height: 16),
            ],

            // ---- Month Expense Breakdown ----
            if (expCats.isNotEmpty) ...[
              _SectionTitle('${formatMonthYear(now)} Expenses'),
              const SizedBox(height: 8),
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: expCats.entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  _categoryIcon(e.key),
                                  const SizedBox(width: 8),
                                  Text(e.key,
                                      style: const TextStyle(fontSize: 13)),
                                ]),
                                Text(formatMoney(e.value),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              )),
              const SizedBox(height: 16),
            ],

            // ---- Active Flocks ----
            if (flocks.active.isNotEmpty) ...[
              const _SectionTitle('Active Flocks'),
              const SizedBox(height: 8),
              ...flocks.active.map((f) => Card(
                      child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: const Icon(Icons.groups,
                          color: AppTheme.primary, size: 20),
                    ),
                    title: Text(f.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${f.activeBirds} active birds'),
                    trailing: f.mortalityCount > 0
                        ? Text('${f.mortalityCount} lost',
                            style: TextStyle(
                                color: Colors.red.shade400, fontSize: 12))
                        : null,
                  ))),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(String cat) {
    const icons = {
      'Feed': Icons.grain,
      'Medication': Icons.medication_outlined,
      'Fuel': Icons.local_gas_station_outlined,
      'Salary': Icons.people_outlined,
      'Crates': Icons.inventory_outlined,
      'Repairs': Icons.build_outlined,
      'Other': Icons.more_horiz,
    };
    return Icon(icons[cat] ?? Icons.circle,
        size: 16, color: Colors.grey.shade600);
  }
}

// ---- Quick Action Widget ----
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      );
}

// ---- Supporting Widgets ----
class _Header extends StatelessWidget {
  final String farmName;
  final DateTime now;
  const _Header({required this.farmName, required this.now});

  @override
  Widget build(BuildContext context) {
    final h = now.hour;
    final greeting = h < 12
        ? 'Good morning'
        : h < 17
            ? 'Good afternoon'
            : 'Good evening';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppTheme.primary, AppTheme.light]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 2),
            Text(farmName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(formatDate(now),
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        )),
        const Icon(Icons.agriculture, color: Colors.white38, size: 40),
      ]),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ]),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}

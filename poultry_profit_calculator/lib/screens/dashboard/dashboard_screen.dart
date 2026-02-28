import 'package:flutter/material.dart';
import 'package:poultry_profit_calculator/screens/dashboard/dashboard_charts.dart';
import '../../controllers/profit_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../widgets/result_card.dart';
import '../../widgets/saved_profit_card_expandable.dart';
import '../../utils/currency.dart';
import '../calendar_profit_view.dart';

class DashboardScreen extends StatefulWidget {
  final ProfitController profitController;
  final TransactionController transactionController;
  final SettingsController settingsController;
  final void Function(int tabIndex) goToTab;

  const DashboardScreen({
    super.key,
    required this.profitController,
    required this.transactionController,
    required this.settingsController,
    required this.goToTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.profitController.records;
    final recentRecords = records.take(5).toList();
    final todayRecord = widget.profitController.lastRecord;

    final now = DateTime.now();
    final hasTodayRecord = todayRecord != null &&
        todayRecord.date.year == now.year &&
        todayRecord.date.month == now.month &&
        todayRecord.date.day == now.day;

    final greeting = _greeting();
    final farmName =
        widget.settingsController.settings.farmName?.isNotEmpty == true
            ? widget.settingsController.settings.farmName!
            : 'Your Farm';

    /// ---------------- DASHBOARD RIBBON ----------------
    final totalIncomeFromSales = widget.transactionController.txBox.values
        .fold<double>(0.0, (sum, tx) => sum + tx.amountPaid);

    const int eggsPerCrate = 30;
    final totalEggsSold = widget.transactionController.txBox.values.fold<int>(
        0, (sum, tx) => sum + (tx.crates * eggsPerCrate) + tx.pieces);

    final totalProfit = widget.profitController.records
        .fold<double>(0.0, (sum, r) => sum + r.profit);

    final totalEggsLaid = widget.profitController.records
        .fold<int>(0, (sum, r) => sum + r.eggsProduced);

    final primary = Theme.of(context).primaryColor;
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            /// ---------------- GREETING ----------------
            FadeTransition(
              opacity: _animController,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary.withValues(alpha: 0.8), primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome to $farmName Poultry Books',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// ---------------- PROFIT SUMMARY RIBBON ----------------
            // Ribbon cards
            Row(
              children: [
                _summaryCard(
                  label: 'Total Profit',
                  value: formatMoney(totalProfit),
                  color: Colors.green.shade400,
                  icon: Icons.savings,
                ),
                // const SizedBox(width: 12),
                // _summaryCard(
                //   label: 'Total Income',
                //   value: formatMoney(totalIncomeFromSales),
                //   color: Colors.blue.shade400,
                //   icon: Icons.wallet,
                // ),
                const SizedBox(width: 12),
                _summaryCard(
                  label: 'Eggs Sold',
                  value: totalEggsSold.toString(),
                  color: Colors.orange.shade400,
                  icon: Icons.egg,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  label: 'Eggs Laid',
                  value: totalEggsLaid.toString(),
                  color: Colors.purple.shade400,
                  icon: Icons.egg_alt,
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// ---------------- TODAY OVERVIEW ----------------
            _sectionHeader('Today Overview'),
            const SizedBox(height: 12),
            hasTodayRecord
                ? ResultCard(
                    profit: todayRecord.profit,
                    eggIncome: todayRecord.eggIncome,
                    feedCost: todayRecord.feedCost,
                    fixedCostPerDay: todayRecord.fixedCostPerDay,
                  )
                : _emptyToday(),
            const SizedBox(height: 24),

            /// ---------------- QUICK ACTIONS ----------------
            _sectionHeader('Quick Actions'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    icon: Icons.calculate,
                    label: 'Calculate Profit',
                    color: accent,
                    onTap: () => widget.goToTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    icon: Icons.calendar_month,
                    label: 'History',
                    color: Colors.deepPurple.shade400,
                    onTap: () => _openCalendar(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            /// ---------------- CHARTS ----------------
            _sectionHeader('Weekly Performance'),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DashboardCharts(controller: widget.profitController),
              ),
            ),
            const SizedBox(height: 28),

            /// ---------------- RECENT RECORDS ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader('Recent Records'),
                TextButton(
                  onPressed: () => _openCalendar(context),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recentRecords.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No profit records yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...recentRecords.map(
                (record) => SavedProfitCardExpandable(
                  record: record,
                  profitController: widget.profitController,
                  onDeleted: () => setState(() {}),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ---------------- HELPERS ----------------

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColorDark,
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyToday() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No profit recorded for today',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  void _openCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarProfitView(
          controller: widget.profitController,
          settingsController: widget.settingsController,
        ),
      ),
    );
  }
}

// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:poultry_books/models/egg_adjustment.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/egg_adjustment_provider.dart';
import '../../core/app_theme.dart';
import '../../utils/formatters.dart';
import '../expenses/expenses_screen.dart';
import '../reports/reports_screen.dart';
import '../flocks/flocks_screen.dart';
import '../sales/sales_screen.dart';
import '../customers/customers_screen.dart';
import '../main_shell.dart';
import '../daily_log/egg_log_history_screen.dart';

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

    // ── Computed values ──────────────────────────────────────────────
    final todayLogs = logs.all.where((l) => isSameDay(l.date, now)).toList();
    final todayEggs = todayLogs.fold(0, (s, l) => s + l.eggsCollected);
    final todayCrates = todayEggs ~/ 30;
    final todayLoose = todayEggs % 30;

    final adjustments = context.watch<EggAdjustmentProvider>();
    final totalSold = sales.totalEggsSold();
    final eggsOnHand = logs.totalEggsOnHand(totalSold,
        netAdjustment: adjustments.netAdjustment);
    final monthIncome = sales.totalIncomeForMonth(now.year, now.month);
    final monthExpenses = expenses.totalForMonth(now.year, now.month);
    final monthProfit = monthIncome - monthExpenses;
    final totalOwing = sales.totalOwingAllCustomers;

    // Last 7 days for trend
    final last7 = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final eggs = logs.all
          .where((l) => isSameDay(l.date, day))
          .fold(0, (s, l) => s + l.eggsCollected);
      return _DayEggs(day: day, eggs: eggs);
    });

    // ── Layout ───────────────────────────────────────────────────────
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ════════════════════════════════════════════════════════
            // HERO — visible without any scrolling
            // ════════════════════════════════════════════════════════
            _Hero(
              farmName: settings.farmName,
              now: now,
              todayEggs: todayEggs,
              todayCrates: todayCrates,
              todayLoose: todayLoose,
              flocks: flocks,
              todayLogs: todayLogs,
            ),

            // ════════════════════════════════════════════════════════
            // KPI STRIP — horizontal scroll, 3 cards
            // ════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
              child: Text('This Month',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
            ),
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                children: [
                  _KpiCard(
                    label: 'Profit',
                    value: formatMoney(monthProfit),
                    icon: Icons.account_balance_outlined,
                    color: monthProfit >= 0
                        ? Colors.green.shade600
                        : Colors.red.shade500,
                  ),
                  _KpiCard(
                    label: 'Income',
                    value: formatMoney(monthIncome),
                    icon: Icons.trending_up,
                    color: Colors.blue.shade600,
                  ),
                  _KpiCard(
                    label: 'Expenses',
                    value: formatMoney(monthExpenses),
                    icon: Icons.trending_down,
                    color: Colors.orange.shade600,
                  ),
                  _EggsOnHandCard(
                    eggsOnHand: eggsOnHand,
                    onTap: () => _showEggAdjustmentSheet(context),
                  ),
                  if (totalOwing > 0)
                    _KpiCard(
                      label: 'Outstanding',
                      value: formatMoney(totalOwing),
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red.shade500,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ════════════════════════════════════════════════════════
            // 7-DAY TREND
            // ════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _EggTrendChart(data: last7),
            ),

            const SizedBox(height: 16),

            // ════════════════════════════════════════════════════════
            // QUICK ACTIONS — 4×2 grid
            // ════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text('Quick Actions',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
                children: [
                  _QuickAction(
                    icon: Icons.add_circle_outline,
                    label: 'New Sale',
                    color: Colors.green.shade600,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SaleFormScreen())),
                  ),
                  _QuickAction(
                    icon: Icons.payments_outlined,
                    label: 'Add Expense',
                    color: Colors.red.shade400,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpenseFormScreen())),
                  ),
                  _QuickAction(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reports',
                    color: Colors.purple.shade400,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReportsScreen())),
                  ),
                  _QuickAction(
                    icon: Icons.groups_outlined,
                    label: 'Flocks',
                    color: AppTheme.primary,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FlocksScreen())),
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
                    icon: Icons.history,
                    label: 'Egg History',
                    color: Colors.teal.shade600,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EggLogHistoryScreen())),
                  ),
                  _QuickAction(
                    icon: Icons.person_outlined,
                    label: 'Customers',
                    color: Colors.blue.shade500,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CustomersScreen())),
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
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// EGG ADJUSTMENT SHEET — shown when user taps Eggs on Hand card
// ════════════════════════════════════════════════════════════════════
void _showEggAdjustmentSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => const _EggAdjustmentSheet(),
  );
}

// ════════════════════════════════════════════════════════════════════
// EGGS ON HAND CARD — tappable KPI card with long-press hint
// ════════════════════════════════════════════════════════════════════
class _EggsOnHandCard extends StatelessWidget {
  final int eggsOnHand;
  final VoidCallback onTap;
  const _EggsOnHandCard({required this.eggsOnHand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Colors.purple.shade500;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(formatEggs(eggsOnHand),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: color),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  Row(children: [
                    Expanded(
                      child: Text('Eggs on Hand',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    Icon(Icons.tune, size: 10, color: color.withOpacity(0.5)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// EGG ADJUSTMENT BOTTOM SHEET
// ════════════════════════════════════════════════════════════════════
class _EggAdjustmentSheet extends StatefulWidget {
  const _EggAdjustmentSheet();
  @override
  State<_EggAdjustmentSheet> createState() => _EggAdjustmentSheetState();
}

class _EggAdjustmentSheetState extends State<_EggAdjustmentSheet> {
  // 0 = pick action, 1 = record loss, 2 = correct stock
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),

              if (_step == 0) ...[
                const Text('Adjust Eggs on Hand',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Correct your egg stock when the app count '
                  'doesn\'t match reality.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),
                _OptionTile(
                  icon: Icons.broken_image_outlined,
                  iconColor: Colors.orange.shade600,
                  title: 'Record Egg Loss',
                  subtitle: 'Broken, rotten, stolen, eaten at home, given away',
                  onTap: () => setState(() => _step = 1),
                ),
                const SizedBox(height: 10),
                _OptionTile(
                  icon: Icons.inventory_outlined,
                  iconColor: Colors.blue.shade600,
                  title: 'Correct Stock Count',
                  subtitle:
                      'Physical count differs from app — set the real number',
                  onTap: () => setState(() => _step = 2),
                ),
                const SizedBox(height: 10),
                _OptionTile(
                  icon: Icons.history,
                  iconColor: Colors.grey.shade600,
                  title: 'View Adjustment History',
                  subtitle: 'See all past losses and corrections',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const EggAdjustmentHistoryScreen()));
                  },
                ),
              ] else if (_step == 1) ...[
                _LossForm(onBack: () => setState(() => _step = 0)),
              ] else ...[
                _StockCorrectionForm(onBack: () => setState(() => _step = 0)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Option Tile ──────────────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withOpacity(0.15)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            )),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ]),
        ),
      );
}

// ── Loss Form ────────────────────────────────────────────────────────
class _LossForm extends StatefulWidget {
  final VoidCallback onBack;
  const _LossForm({required this.onBack});
  @override
  State<_LossForm> createState() => _LossFormState();
}

class _LossFormState extends State<_LossForm> {
  final _eggsCtrl = TextEditingController();
  String _reason = 'Broken/Cracked';
  final _customCtrl = TextEditingController();

  static const _reasons = [
    'Broken/Cracked',
    'Rotten/Spoiled',
    'Eaten at Home',
    'Given Away',
    'Stolen',
    'Other',
  ];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),
            const SizedBox(width: 8),
            const Text('Record Egg Loss',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _eggsCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Number of Eggs Lost',
              prefixIcon: Icon(Icons.egg_outlined),
              hintText: 'e.g. 15',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _reason,
            decoration: const InputDecoration(
                labelText: 'Reason', prefixIcon: Icon(Icons.help_outline)),
            items: _reasons
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _reason = v!),
          ),
          if (_reason == 'Other') ...[
            const SizedBox(height: 14),
            TextField(
              controller: _customCtrl,
              decoration: const InputDecoration(
                  labelText: 'Describe the reason',
                  prefixIcon: Icon(Icons.note_outlined)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600),
              onPressed: () async {
                final eggs = int.tryParse(_eggsCtrl.text) ?? 0;
                if (eggs <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Enter number of eggs lost')));
                  return;
                }
                final finalReason = _reason == 'Other'
                    ? (_customCtrl.text.trim().isEmpty
                        ? 'Other'
                        : _customCtrl.text.trim())
                    : _reason;
                await context
                    .read<EggAdjustmentProvider>()
                    .recordLoss(eggs: eggs, reason: finalReason);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('$eggs eggs recorded as lost ($finalReason)')));
                }
              },
              child: const Text('Save Loss'),
            ),
          ),
        ],
      );
}

// ── Stock Correction Form ────────────────────────────────────────────
class _StockCorrectionForm extends StatefulWidget {
  final VoidCallback onBack;
  const _StockCorrectionForm({required this.onBack});
  @override
  State<_StockCorrectionForm> createState() => _StockCorrectionFormState();
}

class _StockCorrectionFormState extends State<_StockCorrectionForm> {
  final _actualCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<DailyLogProvider>();
    final sales = context.watch<SaleProvider>();
    final adjustments = context.watch<EggAdjustmentProvider>();
    final currentOnHand = logs.totalEggsOnHand(sales.totalEggsSold(),
        netAdjustment: adjustments.netAdjustment);
    final actualTyped = int.tryParse(_actualCtrl.text);
    final diff = actualTyped != null ? actualTyped - currentOnHand : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
          const SizedBox(width: 8),
          const Text('Correct Stock Count',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        // Current app count
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(children: [
            Icon(Icons.phone_android, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text('App currently shows: ',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            Text(formatEggs(currentOnHand),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _actualCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Actual eggs you physically counted',
            prefixIcon: Icon(Icons.egg_outlined),
            hintText: 'e.g. 450',
          ),
          onChanged: (_) => setState(() {}),
        ),
        // Live diff preview
        if (diff != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: diff >= 0 ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color:
                      diff >= 0 ? Colors.green.shade100 : Colors.red.shade100),
            ),
            child: Row(children: [
              Icon(
                diff >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: diff >= 0 ? Colors.green.shade700 : Colors.red.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                diff >= 0
                    ? 'Stock will increase by ${diff.abs()} eggs'
                    : 'Stock will decrease by ${diff.abs()} eggs',
                style: TextStyle(
                    fontSize: 12,
                    color:
                        diff >= 0 ? Colors.green.shade700 : Colors.red.shade600,
                    fontWeight: FontWeight.w500),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: actualTyped == null || actualTyped < 0
                ? null
                : () async {
                    await context.read<EggAdjustmentProvider>().correctStock(
                          actualOnHand: actualTyped,
                          currentOnHand: currentOnHand,
                          reason: 'Physical count correction',
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Stock count corrected')));
                    }
                  },
            child: const Text('Save Correction'),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// ADJUSTMENT HISTORY SCREEN
// ════════════════════════════════════════════════════════════════════
class EggAdjustmentHistoryScreen extends StatelessWidget {
  const EggAdjustmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adjustments = context.watch<EggAdjustmentProvider>().all;

    return Scaffold(
      appBar: AppBar(title: const Text('Egg Adjustment History')),
      body: adjustments.isEmpty
          ? Center(
              child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('No adjustments yet',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Losses and stock corrections will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500)),
                  ]),
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adjustments.length,
              itemBuilder: (_, i) {
                final adj = adjustments[i];
                final isLoss = adj.type == AdjustmentType.loss;
                final effect = adj.signedEffect;
                final color =
                    isLoss ? Colors.red.shade600 : Colors.blue.shade600;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(
                        isLoss
                            ? Icons.broken_image_outlined
                            : Icons.inventory_outlined,
                        color: color,
                        size: 18,
                      ),
                    ),
                    title: Text(adj.reason,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(formatDate(adj.date)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${effect >= 0 ? '+' : ''}$effect eggs',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: effect >= 0
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                              fontSize: 13),
                        ),
                        Text(
                          isLoss ? 'Loss' : 'Correction',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// HERO — greeting + farm name + today's egg count prominently
// ════════════════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  final String farmName;
  final DateTime now;
  final int todayEggs, todayCrates, todayLoose;
  final FlockProvider flocks;
  final List todayLogs;

  const _Hero({
    required this.farmName,
    required this.now,
    required this.todayEggs,
    required this.todayCrates,
    required this.todayLoose,
    required this.flocks,
    required this.todayLogs,
  });

  @override
  Widget build(BuildContext context) {
    final h = now.hour;
    final greeting = h < 12
        ? 'Good morning'
        : h < 17
            ? 'Good afternoon'
            : 'Good evening';

    // Build per-flock breakdown only when more than one flock is active
    final activeFlocksWithEggs = flocks.active.where((f) {
      final eggs = todayLogs
          .where((l) => l.flockId == f.id)
          .fold(0, (s, l) => s + (l.eggsCollected as int));
      return eggs > 0;
    }).toList();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.light],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(farmName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                    Text(formatDate(now),
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11)),
                  ]),
            ),
            const Icon(Icons.agriculture, color: Colors.white24, size: 38),
          ]),

          const SizedBox(height: 20),

          // TODAY'S EGGS — the big number
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Flexible(
                  child: Text(
                    todayEggs > 0 ? '$todayEggs' : '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        height: 1),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    todayEggs > 0 ? 'eggs today' : 'no eggs logged yet',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ]),
              if (todayEggs > 0) ...[
                const SizedBox(height: 4),
                Text(
                  todayCrates > 0 && todayLoose > 0
                      ? '$todayCrates crates + $todayLoose loose'
                      : todayCrates > 0
                          ? '$todayCrates crates'
                          : '$todayLoose loose eggs',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),

                // Per-flock breakdown (only if multiple flocks logged)
                if (activeFlocksWithEggs.length > 1) ...[
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 0),
                  const SizedBox(height: 8),
                  ...activeFlocksWithEggs.map((f) {
                    final eggs = todayLogs
                        .where((l) => l.flockId == f.id)
                        .fold(0, (s, l) => s + (l.eggsCollected as int));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        Expanded(
                            child: Text(f.name,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                                overflow: TextOverflow.ellipsis)),
                        Text('$eggs eggs',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ]),
                    );
                  }),
                ],
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// KPI CARD — horizontal scroll strip
// ════════════════════════════════════════════════════════════════════
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
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: color),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  const SizedBox(height: 2),
                  Text(label,
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════════════
// 7-DAY EGG TREND CHART
// ════════════════════════════════════════════════════════════════════
class _DayEggs {
  final DateTime day;
  final int eggs;
  const _DayEggs({required this.day, required this.eggs});
}

class _EggTrendChart extends StatelessWidget {
  final List<_DayEggs> data;
  const _EggTrendChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxEggs = data.map((d) => d.eggs).fold(0, (a, b) => a > b ? a : b);
    final hasData = maxEggs > 0;
    final total = data.fold(0, (s, d) => s + d.eggs);
    final avg = (total / 7).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('7-Day Egg Trend',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
          ),
          if (hasData)
            Text('avg $avg/day',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ]),
        const SizedBox(height: 12),
        if (!hasData)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No egg data yet',
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 13)),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final frac = maxEggs > 0 ? d.eggs / maxEggs : 0.0;
                final isToday = isSameDay(d.day, DateTime.now());

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (d.eggs > 0)
                          Text(
                            d.eggs >= 1000
                                ? '${(d.eggs / 1000).toStringAsFixed(1)}k'
                                : '${d.eggs}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? AppTheme.primary
                                  : Colors.grey.shade500,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: (frac * 70).clamp(3.0, 70.0),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppTheme.primary
                                : AppTheme.primary.withOpacity(0.35),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _label(d.day),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? AppTheme.primary
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ]),
    );
  }

  String _label(DateTime d) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return isSameDay(d, DateTime.now()) ? '•' : days[d.weekday - 1];
  }
}

// ════════════════════════════════════════════════════════════════════
// QUICK ACTION BUTTON
// ════════════════════════════════════════════════════════════════════
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
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
            ],
          ),
        ),
      );
}

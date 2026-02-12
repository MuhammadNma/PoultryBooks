// import 'package:flutter/material.dart';
// import 'package:poultry_profit_calculator/screens/dashboard/dashboard_charts.dart';
// import '../../controllers/profit_controller.dart';
// import '../../controllers/settings_controller.dart';
// import '../../widgets/result_card.dart';
// import '../../widgets/saved_profit_card_expandable.dart';
// import '../calendar_profit_view.dart';

// class DashboardScreen extends StatefulWidget {
//   final ProfitController profitController;
//   final SettingsController settingsController;
//   final void Function(int tabIndex) goToTab;

//   const DashboardScreen({
//     super.key,
//     required this.profitController,
//     required this.settingsController,
//     required this.goToTab,
//   });

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final recentRecords = widget.profitController.records.take(5).toList();
//     final todayRecord = widget.profitController.lastRecord;
//     final hasTodayRecord = todayRecord != null &&
//         todayRecord.date.year == DateTime.now().year &&
//         todayRecord.date.month == DateTime.now().month &&
//         todayRecord.date.day == DateTime.now().day;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Dashboard')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Today's Profit Summary
//             const Text(
//               'Today\'s Profit Summary',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             if (hasTodayRecord)
//               ResultCard(
//                 profit: todayRecord.profit,
//                 eggIncome: todayRecord.eggIncome,
//                 feedCost: todayRecord.feedCost,
//                 fixedCostPerDay: todayRecord.fixedCostPerDay,
//               )
//             else
//               const Card(
//                 margin: EdgeInsets.symmetric(vertical: 6),
//                 child: Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Text('No profit recorded today'),
//                 ),
//               ),

//             const SizedBox(height: 20),

//             // Quick Actions
//             const Text(
//               'Quick Actions',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     widget.goToTab(1); // Profit Calculator tab
//                   },
//                   icon: const Icon(Icons.calculate),
//                   label: const Text('Calculate Profit'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => CalendarProfitView(
//                           controller: widget.profitController,
//                           settingsController: widget.settingsController,
//                         ),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.calendar_today),
//                   label: const Text('View History'),
//                 ),
//               ],
//             ),
//             const Text(
//               'Charts',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             DashboardCharts(controller: widget.profitController),

//             const SizedBox(height: 20),

//             // Recent Records
//             const Text(
//               'Recent Profit Records',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Column(
//               children: recentRecords.isEmpty
//                   ? [const Text('No profit records yet.')]
//                   : recentRecords
//                       .map((record) => SavedProfitCardExpandable(
//                             record: record,
//                             profitController: widget.profitController,
//                             onDeleted: () => setState(() {}),
//                           ))
//                       .toList(),
//             ),
//             const SizedBox(height: 12),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => CalendarProfitView(
//                       controller: widget.profitController,
//                       settingsController: widget.settingsController,
//                     ),
//                   ),
//                 );
//               },
//               child: const Text('View More', style: TextStyle(fontSize: 16)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:poultry_profit_calculator/screens/dashboard/dashboard_charts.dart';
import '../../controllers/profit_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/result_card.dart';
import '../../widgets/saved_profit_card_expandable.dart';
import '../calendar_profit_view.dart';

class DashboardScreen extends StatefulWidget {
  final ProfitController profitController;
  final SettingsController settingsController;
  final void Function(int tabIndex) goToTab;

  const DashboardScreen({
    super.key,
    required this.profitController,
    required this.settingsController,
    required this.goToTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final farmName = widget.settingsController.settings.farmName ?? 'Your Farm';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// ---------------- GREETING ----------------
            Text(
              greeting,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome to $farmName Poultry Books',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            /// ---------------- TODAY OVERVIEW ----------------
            _sectionHeader('Today Overview'),
            const SizedBox(height: 8),
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
                    onTap: () => widget.goToTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    icon: Icons.calendar_month,
                    label: 'History',
                    onTap: () => _openCalendar(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            /// ---------------- CHARTS ----------------
            _sectionHeader('Weekly Performance'),
            const SizedBox(height: 8),
            DashboardCharts(controller: widget.profitController),
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
                )),
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
    if (hour < 12) return 'Good morning ';
    if (hour < 17) return 'Good afternoon ';
    return 'Good evening ';
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyToday() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No profit recorded for today',
            style: TextStyle(color: Colors.grey),
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

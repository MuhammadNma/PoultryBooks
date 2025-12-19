// import 'package:flutter/material.dart';
// import '../../controllers/profit_controller.dart';
// import '../profit_calculator_screen.dart';
// import '../calendar_profit_view.dart';
// import '../../widgets/saved_profit_card_expandable.dart';
// import '../../widgets/result_card.dart';

// class DashboardScreen extends StatefulWidget {
//   final ProfitController profitController;

//   const DashboardScreen({super.key, required this.profitController});

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
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) =>
//                               const ProfitCalculatorScreen()), // existing screen
//                     );
//                   },
//                   icon: const Icon(Icons.calculate),
//                   label: const Text('Calculate Profit'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => CalendarProfitView(
//                               controller: widget.profitController)),
//                     );
//                   },
//                   icon: const Icon(Icons.calendar_today),
//                   label: const Text('View History'),
//                 ),
//               ],
//             ),

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
//                       builder: (_) => CalendarProfitView(
//                           controller: widget.profitController)),
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
import '../../controllers/profit_controller.dart';
import '../../widgets/result_card.dart';
import '../../widgets/saved_profit_card_expandable.dart';

class DashboardScreen extends StatefulWidget {
  final ProfitController profitController;
  final void Function(int tabIndex) goToTab;

  const DashboardScreen({
    super.key,
    required this.profitController,
    required this.goToTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final recentRecords = widget.profitController.records.take(5).toList();
    final todayRecord = widget.profitController.lastRecord;
    final hasTodayRecord = todayRecord != null &&
        todayRecord.date.year == DateTime.now().year &&
        todayRecord.date.month == DateTime.now().month &&
        todayRecord.date.day == DateTime.now().day;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Profit Summary
            const Text(
              'Today\'s Profit Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (hasTodayRecord)
              ResultCard(
                profit: todayRecord.profit,
                eggIncome: todayRecord.eggIncome,
                feedCost: todayRecord.feedCost,
                fixedCostPerDay: todayRecord.fixedCostPerDay,
              )
            else
              const Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No profit recorded today'),
                ),
              ),

            const SizedBox(height: 20),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    widget.goToTab(1); // Profit Calculator tab
                  },
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate Profit'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.goToTab(3); // Calendar tab
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('View History'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent Records
            const Text(
              'Recent Profit Records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: recentRecords.isEmpty
                  ? [const Text('No profit records yet.')]
                  : recentRecords
                      .map((record) => SavedProfitCardExpandable(
                            record: record,
                            profitController: widget.profitController,
                            onDeleted: () => setState(() {}),
                          ))
                      .toList(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                widget.goToTab(3); // Calendar tab
              },
              child: const Text('View More', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

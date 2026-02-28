// import 'package:flutter/material.dart';
// import 'package:poultry_profit_calculator/controllers/settings_controller.dart';
// import 'package:table_calendar/table_calendar.dart';
// import '../controllers/profit_controller.dart';
// import '../widgets/saved_profit_card_expandable.dart';
// import 'profit_calculator_screen.dart';

// class CalendarProfitView extends StatefulWidget {
//   final ProfitController controller;
//   final SettingsController settingsController;

//   const CalendarProfitView({
//     super.key,
//     required this.controller,
//     required this.settingsController,
//   });

//   @override
//   State<CalendarProfitView> createState() => _CalendarProfitViewState();
// }

// class _CalendarProfitViewState extends State<CalendarProfitView> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   @override
//   Widget build(BuildContext context) {
//     final record = _selectedDay == null
//         ? null
//         : widget.controller.getRecordByDate(_selectedDay!);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profit History')),
//       body: Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime(2020),
//             lastDay: DateTime.now(),
//             focusedDay: _focusedDay,
//             calendarFormat: CalendarFormat.month,
//             availableCalendarFormats: const {
//               CalendarFormat.month: 'Month',
//             },
//             selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//             // onDaySelected: (selectedDay, focusedDay) {
//             //   setState(() {
//             //     _selectedDay = selectedDay;
//             //     _focusedDay = focusedDay;
//             //   });
//             // },

//             onDaySelected: (selectedDay, focusedDay) async {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay;
//               });

//               final record = widget.controller.getRecordByDate(selectedDay);
//               if (record != null) return;

//               final add = await showDialog<bool>(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text('No Record'),
//                   content: Text(
//                     'No profit record for '
//                     '${selectedDay.toLocal().toString().split(' ')[0]}.\n\n'
//                     'Would you like to add one?',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: const Text('Cancel'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text('Add Record'),
//                     ),
//                   ],
//                 ),
//               );

//               if (add != true) return;
//               if (!mounted) return;

//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ProfitCalculatorScreen(
//                     selectedDate: selectedDay,
//                     profitController: widget.controller,
//                     settingsController: widget.settingsController,
//                   ),
//                 ),
//               );

//               if (!mounted) return;
//               setState(() {});
//             },
//           ),
//           const SizedBox(height: 12),
//           if (record != null)
//             SavedProfitCardExpandable(
//               record: record,
//               profitController: widget.controller,
//               onDeleted: () {
//                 setState(() {
//                   _selectedDay = null;
//                 });
//               },
//             )
//           else if (_selectedDay != null)
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Text('No record for this day'),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:poultry_profit_calculator/controllers/settings_controller.dart';
import '../controllers/profit_controller.dart';
import '../widgets/saved_profit_card_expandable.dart';
import 'profit_calculator_screen.dart';

class CalendarProfitView extends StatefulWidget {
  final ProfitController controller;
  final SettingsController settingsController;

  const CalendarProfitView({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  @override
  State<CalendarProfitView> createState() => _CalendarProfitViewState();
}

class _CalendarProfitViewState extends State<CalendarProfitView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final record = _selectedDay == null
        ? null
        : widget.controller.getRecordByDate(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit History'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          /// Calendar Card
          Card(
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: _onDaySelected,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Profit Record Section
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildProfitSection(record),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitSection(record) {
    if (record != null) {
      return Padding(
        key: ValueKey(record.date),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SavedProfitCardExpandable(
          record: record,
          profitController: widget.controller,
          onDeleted: () {
            setState(() => _selectedDay = null);
          },
        ),
      );
    } else if (_selectedDay != null) {
      return Center(
        key: const ValueKey('no_record'),
        child: Text(
          'No record for ${_selectedDay!.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final record = widget.controller.getRecordByDate(selectedDay);
    if (record != null) return;

    final add = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('No Record'),
        content: Text(
          'No profit record for ${selectedDay.toLocal().toString().split(' ')[0]}.\n\nWould you like to add one?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Record'),
          ),
        ],
      ),
    );

    if (add != true || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfitCalculatorScreen(
          selectedDate: selectedDay,
          profitController: widget.controller,
          settingsController: widget.settingsController,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }
}

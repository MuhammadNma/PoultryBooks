import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/profit_controller.dart';
import '../widgets/saved_profit_card_expandable.dart';
import 'profit_calculator_screen.dart';

class CalendarProfitView extends StatefulWidget {
  final ProfitController controller;

  const CalendarProfitView({super.key, required this.controller});

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
      appBar: AppBar(title: const Text('Profit History')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            // onDaySelected: (selectedDay, focusedDay) {
            //   setState(() {
            //     _selectedDay = selectedDay;
            //     _focusedDay = focusedDay;
            //   });
            // },

            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              final record = widget.controller.getRecordByDate(selectedDay);
              if (record != null) return;

              final add = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('No Record'),
                  content: Text(
                    'No profit record for '
                    '${selectedDay.toLocal().toString().split(' ')[0]}.\n\n'
                    'Would you like to add one?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Add Record'),
                    ),
                  ],
                ),
              );

              if (add != true) return;
              if (!mounted) return;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfitCalculatorScreen(
                    selectedDate: selectedDay,
                  ),
                ),
              );

              if (!mounted) return;
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          if (record != null)
            SavedProfitCardExpandable(
              record: record,
              profitController: widget.controller,
              onDeleted: () {
                setState(() {
                  _selectedDay = null;
                });
              },
            )
          else if (_selectedDay != null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No record for this day'),
            ),
        ],
      ),
    );
  }
}

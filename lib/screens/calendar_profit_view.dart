import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:poultry_books/controllers/settings_controller.dart';
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

  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  bool _calendarExpanded = true;

  int? _expandedIndex;

  String get _rangeLabel {
    if (_rangeStart == null || _rangeEnd == null) {
      return 'Select Range';
    }

    final start = DateFormat('dd MMM yyyy').format(_rangeStart!);
    final end = DateFormat('dd MMM yyyy').format(_rangeEnd!);

    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final record = _selectedDay == null
        ? null
        : widget.controller.getRecordByDate(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Records'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// Collapsible Calendar
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _calendarExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildCalendar(),
            secondChild: const SizedBox.shrink(),
          ),

          TextButton.icon(
            onPressed: () {
              setState(() {
                _calendarExpanded = !_calendarExpanded;
              });
            },
            icon: Icon(_calendarExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
            label: Text(_calendarExpanded ? "Hide Calendar" : "Show Calendar"),
          ),

          /// Range Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: null,
              hint: Text(_rangeLabel),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: const [
                DropdownMenuItem(value: '2w', child: Text('Last 2 Weeks')),
                DropdownMenuItem(value: '1m', child: Text('Last 1 Month')),
                DropdownMenuItem(value: '3m', child: Text('Last 3 Months')),
                DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _applyRange(value);
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          /// Results
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildResults(record),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          onDaySelected: _onDaySelected,
        ),
      ),
    );
  }

  /* ================= RANGE LOGIC ================= */

  Future<void> _applyRange(String value) async {
    final now = DateTime.now();

    if (value == '2w') {
      _rangeStart = now.subtract(const Duration(days: 14));
      _rangeEnd = now;
    } else if (value == '1m') {
      _rangeStart = now.subtract(const Duration(days: 30));
      _rangeEnd = now;
    } else if (value == '3m') {
      _rangeStart = now.subtract(const Duration(days: 90));
      _rangeEnd = now;
    } else if (value == 'custom') {
      final result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (result != null) {
        _rangeStart = result.start;
        _rangeEnd = result.end;
      } else {
        return;
      }
    }

    setState(() {
      _selectedDay = null;
      _calendarExpanded = false;
      _expandedIndex = null;
    });
  }

  /* ================= RESULTS ================= */

  Widget _buildResults(record) {
    if (_rangeStart != null && _rangeEnd != null) {
      final records = widget.controller.records.where((r) {
        final d = DateTime(r.date.year, r.date.month, r.date.day);
        return !d.isBefore(_rangeStart!) && !d.isAfter(_rangeEnd!);
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (records.isEmpty) {
        return const Center(child: Text('No records found.'));
      }

      final totalProfit = records.fold<double>(0, (sum, r) => sum + r.profit);

      final totalEggs =
          records.fold<double>(0, (sum, r) => sum + r.eggsProduced);

      // final totalSales = records.fold<double>(0, (sum, r) => sum + r.eggIncome);

      return Column(
        children: [
          /// Compact Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Profit: ₦${totalProfit.toInt()}"),
                Text("Eggs: ${totalEggs.toInt()}"),
                // Text("Sales: ₦${totalSales.toInt()}"),
              ],
            ),
          ),

          /// Expandable Records
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];

                return SavedProfitCardExpandable(
                  record: r,
                  profitController: widget.controller,
                  isExpanded: _expandedIndex == index,
                  onTap: () {
                    setState(() {
                      _expandedIndex = _expandedIndex == index ? null : index;
                    });
                  },
                  onDeleted: () {
                    setState(() {
                      _expandedIndex = null;
                    });
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    /// Single Day View
    if (record != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SavedProfitCardExpandable(
          record: record,
          profitController: widget.controller,
          isExpanded: true, // always expanded for single view
          onTap: () {}, // no toggle needed here
          onDeleted: () {
            setState(() => _selectedDay = null);
          },
        ),
      );
    }

    return const Center(
      child: Text("Select a date or range"),
    );
  }

  /* ================= SINGLE DAY ================= */

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _calendarExpanded = false;
      _expandedIndex = null;
    });

    final record = widget.controller.getRecordByDate(selectedDay);
    if (record != null) return;

    final add = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No Record'),
        content: Text(
          'No profit record for ${DateFormat('dd MMM yyyy').format(selectedDay)}.\n\nWould you like to add one?',
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

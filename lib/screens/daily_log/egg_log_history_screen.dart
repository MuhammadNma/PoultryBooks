// lib/screens/daily_log/egg_log_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/flock_provider.dart';
import '../../models/daily_log.dart';
import '../../core/app_theme.dart';
import '../../utils/formatters.dart';

class EggLogHistoryScreen extends StatefulWidget {
  const EggLogHistoryScreen({super.key});
  @override State<EggLogHistoryScreen> createState() =>
      _EggLogHistoryScreenState();
}

class _EggLogHistoryScreenState extends State<EggLogHistoryScreen> {
  DateTime _month  = DateTime.now();
  String? _flockId; // null = all flocks

  void _prev() => setState(() =>
      _month = DateTime(_month.year, _month.month - 1));

  void _next() {
    final now = DateTime.now();
    if (_month.year == now.year && _month.month == now.month) return;
    setState(() => _month = DateTime(_month.year, _month.month + 1));
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final logProvider   = context.watch<DailyLogProvider>();
    final flockProvider = context.watch<FlockProvider>();
    final flocks        = flockProvider.all;

    final monthLogs = logProvider
        .forMonth(_month.year, _month.month, flockId: _flockId)
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalEggs      = monthLogs.fold(0, (s, l) => s + l.eggsCollected);
    final totalMortality = monthLogs.fold(0, (s, l) => s + l.mortality);
    final totalCrates    = totalEggs ~/ 30;
    final looseEggs      = totalEggs % 30;

    return Scaffold(
      appBar: AppBar(title: const Text('Egg Log History')),
      body: Column(children: [

        // Month selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left)),
            Expanded(child: Column(children: [
              Text(formatMonthYear(_month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                totalEggs > 0
                    ? '$totalCrates crates + $looseEggs pcs ($totalEggs eggs)'
                    : 'No eggs logged',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600),
              ),
            ])),
            IconButton(
              onPressed: _isCurrentMonth ? null : _next,
              icon: Icon(Icons.chevron_right,
                  color: _isCurrentMonth ? Colors.grey.shade300 : null),
            ),
          ]),
        ),
        const Divider(height: 0),

        // Flock filter chips
        if (flocks.length > 1)
          SizedBox(height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              children: [
                _flockChip('All Flocks', null),
                ...flocks.map((f) => _flockChip(f.name, f.id)),
              ],
            ),
          ),

        // Monthly summary bar
        if (monthLogs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              _SummaryPill(
                icon: Icons.egg,
                label: formatEggs(totalEggs),
                color: AppTheme.primary,
              ),
              const SizedBox(width: 10),
              _SummaryPill(
                icon: Icons.calendar_today,
                label: '${monthLogs.length} days logged',
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 10),
              if (totalMortality > 0)
                _SummaryPill(
                  icon: Icons.remove_circle_outline,
                  label: '$totalMortality died',
                  color: Colors.red.shade400,
                ),
            ]),
          ),

        const SizedBox(height: 8),

        // Log list
        Expanded(
          child: monthLogs.isEmpty
            ? Center(child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(Icons.egg_outlined, size: 64,
                      color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No egg logs for ${formatMonthYear(_month)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Use the arrows to browse other months.',
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center),
                ]),
              ))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: monthLogs.length,
                itemBuilder: (_, i) {
                  final log   = monthLogs[i];
                  final flock = flockProvider.getById(log.flockId);
                  return _LogTile(log: log, flockName: flock?.name);
                },
              ),
        ),
      ]),
    );
  }

  Widget _flockChip(String label, String? value) {
    final selected = _flockId == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(() => _flockId = value),
        selectedColor: AppTheme.primary.withOpacity(0.15),
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : Colors.grey.shade700,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final DailyLog log;
  final String? flockName;
  const _LogTile({required this.log, this.flockName});

  @override
  Widget build(BuildContext context) {
    final crates = log.eggsCollected ~/ 30;
    final pieces = log.eggsCollected % 30;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: const Icon(Icons.egg, color: AppTheme.primary, size: 20),
        ),
        title: Row(children: [
          Text(formatDate(log.date),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          if (flockName != null) ...[
            const SizedBox(width: 8),
            Expanded(child: Text(flockName!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                overflow: TextOverflow.ellipsis)),
          ],
        ]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crates > 0 && pieces > 0
                  ? '$crates crates + $pieces pcs'
                  : crates > 0
                      ? '$crates crates'
                      : '$pieces pcs',
              style: TextStyle(color: AppTheme.primary,
                  fontWeight: FontWeight.w600),
            ),
            if (log.mortality > 0)
              Text('${log.mortality} died',
                  style: TextStyle(
                      fontSize: 11, color: Colors.red.shade400)),
            if (log.notes != null)
              Text(log.notes!,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${log.eggsCollected}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primary)),
            Text('eggs', style: TextStyle(
                fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(fontSize: 12, color: color,
              fontWeight: FontWeight.w600)),
    ]),
  );
}

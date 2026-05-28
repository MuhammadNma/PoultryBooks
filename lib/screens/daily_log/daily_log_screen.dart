// lib/screens/daily_log/daily_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/flock_provider.dart';
import '../../models/daily_log.dart';
import '../../models/flock.dart';
import '../../utils/formatters.dart';
import '../../core/app_theme.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});
  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final flocks = context.watch<FlockProvider>().active;
    final logs = context.watch<DailyLogProvider>();
    final isToday = isSameDay(_selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Egg Log')),
      body: Column(children: [
        // Date picker bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppTheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                    isToday
                        ? 'Today — ${formatDate(_selectedDate)}'
                        : formatDate(_selectedDate),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                Text('Change',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),

        // Flock list
        Expanded(
          child: flocks.isEmpty
              ? const _NoFlocks()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: flocks.length,
                  itemBuilder: (_, i) {
                    final flock = flocks[i];
                    final log = logs.getForDate(_selectedDate, flock.id);
                    return _FlockLogCard(
                      flock: flock,
                      log: log,
                      date: _selectedDate,
                      onSave: (eggs, mortality, notes) async {
                        if (log != null) {
                          log.eggsCollected = eggs;
                          log.mortality = mortality;
                          log.notes = notes;
                          log.synced = false;
                          await logs.update(log);
                          // Update flock mortality total
                          if (mortality > 0) {
                            await context
                                .read<FlockProvider>()
                                .addMortality(flock.id, mortality);
                          }
                        } else {
                          await logs.add(DailyLog(
                            id: const Uuid().v4(),
                            date: _selectedDate,
                            flockId: flock.id,
                            eggsCollected: eggs,
                            mortality: mortality,
                            notes: notes,
                          ));
                          if (mortality > 0) {
                            await context
                                .read<FlockProvider>()
                                .addMortality(flock.id, mortality);
                          }
                        }
                      },
                      onDelete: log == null ? null : () => logs.delete(log),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

class _FlockLogCard extends StatefulWidget {
  final Flock flock;
  final DailyLog? log;
  final DateTime date;
  final Future<void> Function(int eggs, int mortality, String? notes) onSave;
  final VoidCallback? onDelete;

  const _FlockLogCard({
    required this.flock,
    required this.log,
    required this.date,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_FlockLogCard> createState() => _FlockLogCardState();
}

class _FlockLogCardState extends State<_FlockLogCard> {
  late TextEditingController _eggsCtrl;
  late TextEditingController _mortalityCtrl;
  late TextEditingController _notesCtrl;
  bool _saving = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _eggsCtrl =
        TextEditingController(text: widget.log?.eggsCollected.toString() ?? '');
    _mortalityCtrl =
        TextEditingController(text: widget.log?.mortality.toString() ?? '0');
    _notesCtrl = TextEditingController(text: widget.log?.notes ?? '');
  }

  @override
  void didUpdateWidget(_FlockLogCard old) {
    super.didUpdateWidget(old);
    if (old.log != widget.log || old.date != widget.date) {
      _eggsCtrl.text = widget.log?.eggsCollected.toString() ?? '';
      _mortalityCtrl.text = widget.log?.mortality.toString() ?? '0';
      _notesCtrl.text = widget.log?.notes ?? '';
    }
  }

  Future<void> _save() async {
    final eggs = int.tryParse(_eggsCtrl.text) ?? 0;
    final mortality = int.tryParse(_mortalityCtrl.text) ?? 0;
    setState(() => _saving = true);
    await widget.onSave(eggs, mortality,
        _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim());
    if (mounted) setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${widget.flock.name} logged — ${formatEggs(eggs)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLog = widget.log != null;
    final eggs = widget.log?.eggsCollected ?? 0;
    final mortality = widget.log?.mortality ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: hasLog
                  ? AppTheme.primary.withOpacity(0.1)
                  : Colors.grey.shade100,
              child: Icon(hasLog ? Icons.check : Icons.egg_outlined,
                  color: hasLog ? AppTheme.primary : Colors.grey.shade400,
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(widget.flock.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${widget.flock.activeBirds} active birds',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ])),
            if (hasLog) ...[
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formatEggs(eggs),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppTheme.primary)),
                if (mortality > 0)
                  Text('$mortality died',
                      style:
                          TextStyle(fontSize: 11, color: Colors.red.shade400)),
              ]),
              const SizedBox(width: 8),
            ],
            IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.edit_outlined,
                  size: 20),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ]),

          // Input form
          if (_expanded) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                controller: _eggsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Eggs Collected',
                  prefixIcon: Icon(Icons.egg_outlined),
                  hintText: '0',
                ),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: TextField(
                controller: _mortalityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Deaths Today',
                  prefixIcon: Icon(Icons.remove_circle_outline),
                  hintText: '0',
                ),
              )),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note_outlined),
                hintText: 'e.g. vaccinated today',
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              if (hasLog && widget.onDelete != null)
                Expanded(
                    child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red)),
                  onPressed: () {
                    widget.onDelete!();
                    setState(() => _expanded = false);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                )),
              if (hasLog && widget.onDelete != null) const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(hasLog ? 'Update' : 'Save'),
              )),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _NoFlocks extends StatelessWidget {
  const _NoFlocks();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.groups_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No active flocks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Add a flock first, then come back to log daily egg collection.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500)),
          ]),
        ),
      );
}

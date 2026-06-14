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
import '../../core/constants.dart';

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
    final isToday = isSameDay(_selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Egg Log')),
      body: Column(children: [
        // Date picker
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
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
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
                    final log = context
                        .watch<DailyLogProvider>()
                        .getForDate(_selectedDate, flock.id);
                    return _FlockLogCard(
                      flock: flock,
                      log: log,
                      date: _selectedDate,
                      onSave: (eggs, mortality, notes) async {
                        final logProvider = context.read<DailyLogProvider>();
                        final flockProvider = context.read<FlockProvider>();

                        if (log != null) {
                          final previousMortality = log.mortality;
                          final mortalityDiff = mortality - previousMortality;

                          log.eggsCollected = eggs;
                          log.mortality = mortality;
                          log.notes = notes;
                          log.synced = false;
                          await logProvider.update(log);

                          if (mortalityDiff > 0) {
                            await flockProvider.addMortality(
                                flock.id, mortalityDiff);
                          } else if (mortalityDiff < 0) {
                            final f = flockProvider.getById(flock.id);
                            if (f != null) {
                              f.mortalityCount =
                                  (f.mortalityCount + mortalityDiff)
                                      .clamp(0, f.numberOfBirds);
                              await flockProvider.update(f);
                            }
                          }
                        } else {
                          await logProvider.add(DailyLog(
                            id: const Uuid().v4(),
                            date: _selectedDate,
                            flockId: flock.id,
                            eggsCollected: eggs,
                            mortality: mortality,
                            notes: notes,
                          ));
                          if (mortality > 0) {
                            await flockProvider.addMortality(
                                flock.id, mortality);
                          }
                        }
                      },
                      onDelete: log == null
                          ? null
                          : () async {
                              if (log.mortality > 0) {
                                final f = context
                                    .read<FlockProvider>()
                                    .getById(flock.id);
                                if (f != null) {
                                  f.mortalityCount =
                                      (f.mortalityCount - log.mortality)
                                          .clamp(0, f.numberOfBirds);
                                  await context.read<FlockProvider>().update(f);
                                }
                              }
                              await context
                                  .read<DailyLogProvider>()
                                  .delete(log);
                            },
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
  final Future<void> Function()? onDelete;

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
  late TextEditingController _cratesCtrl;
  late TextEditingController _piecesCtrl;
  late TextEditingController _mortalityCtrl;
  late TextEditingController _notesCtrl;
  bool _saving = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final log = widget.log;
    // Convert stored egg count back to crates + pieces
    final crates =
        log != null ? log.eggsCollected ~/ AppConstants.eggsPerCrate : 0;
    final pieces =
        log != null ? log.eggsCollected % AppConstants.eggsPerCrate : 0;

    _cratesCtrl =
        TextEditingController(text: log != null ? crates.toString() : '');
    _piecesCtrl =
        TextEditingController(text: log != null ? pieces.toString() : '');
    _mortalityCtrl =
        TextEditingController(text: log?.mortality.toString() ?? '0');
    _notesCtrl = TextEditingController(text: log?.notes ?? '');
  }

  @override
  void didUpdateWidget(_FlockLogCard old) {
    super.didUpdateWidget(old);
    if (old.log != widget.log || old.date != widget.date) {
      final log = widget.log;
      final crates =
          log != null ? log.eggsCollected ~/ AppConstants.eggsPerCrate : 0;
      final pieces =
          log != null ? log.eggsCollected % AppConstants.eggsPerCrate : 0;
      _cratesCtrl.text = log != null ? crates.toString() : '';
      _piecesCtrl.text = log != null ? pieces.toString() : '';
      _mortalityCtrl.text = log?.mortality.toString() ?? '0';
      _notesCtrl.text = log?.notes ?? '';
    }
  }

  Future<void> _save() async {
    final crates = int.tryParse(_cratesCtrl.text) ?? 0;
    final pieces = int.tryParse(_piecesCtrl.text) ?? 0;
    final mortality = int.tryParse(_mortalityCtrl.text) ?? 0;

    // Convert crates + pieces to total eggs
    final totalEggs = (crates * AppConstants.eggsPerCrate) + pieces;

    setState(() => _saving = true);
    await widget.onSave(
      totalEggs,
      mortality,
      _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (mounted) {
      setState(() {
        _saving = false;
        _expanded = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${widget.flock.name} — $crates crates + $pieces pcs logged')));
    }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
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
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              if (hasLog) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatEggs(eggs),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary)),
                    if (mortality > 0)
                      Text('$mortality died',
                          style: TextStyle(
                              fontSize: 11, color: Colors.red.shade400)),
                  ],
                ),
                const SizedBox(width: 4),
              ],
              IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.edit_outlined,
                    size: 20),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ]),

            // Expanded input form
            if (_expanded) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Crates + Pieces row
              const Text('Eggs Collected',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.primary)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _cratesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Crates',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      suffixText: '×${AppConstants.eggsPerCrate}',
                      suffixStyle:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _piecesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Loose Pieces',
                      hintText: '0',
                      prefixIcon: Icon(Icons.egg_outlined),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ]),

              // Live total preview
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total eggs',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                    Text(
                      formatEggs(
                        ((int.tryParse(_cratesCtrl.text) ?? 0) *
                                AppConstants.eggsPerCrate) +
                            (int.tryParse(_piecesCtrl.text) ?? 0),
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Mortality
              TextField(
                controller: _mortalityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Deaths Today',
                    prefixIcon: Icon(Icons.remove_circle_outline),
                    hintText: '0'),
              ),
              const SizedBox(height: 12),

              // Notes
              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.note_outlined),
                    hintText: 'e.g. vaccinated today'),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(children: [
                if (hasLog && widget.onDelete != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red)),
                      onPressed: () async {
                        await widget.onDelete!();
                        if (mounted) {
                          setState(() => _expanded = false);
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
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
                  ),
                ),
              ]),
            ],
          ],
        ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups_outlined,
                  size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('No active flocks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Add a flock first from Dashboard → Quick Access → Flocks.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
}

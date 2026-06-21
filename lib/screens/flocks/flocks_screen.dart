// lib/screens/flocks/flocks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/flock_provider.dart';
import '../../models/flock.dart';
import '../../utils/formatters.dart';
import '../../core/app_theme.dart';

class FlocksScreen extends StatelessWidget {
  const FlocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final all = context.watch<FlockProvider>().all;
    final active = all.where((f) => f.isActive).toList();
    final retired = all.where((f) => !f.isActive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Flocks')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'flocks_fab',
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Flock'),
      ),
      body: all.isEmpty
          ? _Empty(onAdd: () => _openForm(context, null))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                if (active.isNotEmpty) ...[
                  _SectionHeader(label: 'Active Flocks', count: active.length),
                  ...active.map((f) => _FlockCard(
                        flock: f,
                        onEdit: () => _openForm(context, f),
                        onDelete: () => _confirmDelete(context, f),
                        onMortality: () => _recordMortality(context, f),
                        onRetire: () => _confirmRetire(context, f),
                        onReactivate: null,
                      )),
                ],
                if (retired.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionHeader(
                      label: 'Retired Flocks', count: retired.length),
                  ...retired.map((f) => _FlockCard(
                        flock: f,
                        onEdit: () => _openForm(context, f),
                        onDelete: () => _confirmDelete(context, f),
                        onMortality: null,
                        onRetire: null,
                        onReactivate: () => _reactivate(context, f),
                      )),
                ],
              ],
            ),
    );
  }

  void _openForm(BuildContext context, Flock? flock) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => FlockFormScreen(existing: flock)));

  void _confirmDelete(BuildContext context, Flock flock) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Flock?'),
        content: Text(
            'Delete "${flock.name}"? Daily logs linked to this flock will remain.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<FlockProvider>().delete(flock.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmRetire(BuildContext context, Flock flock) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retire This Flock?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Retiring "${flock.name}" means this batch cycle is complete. '
              'The flock will no longer appear in the daily log form.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(children: [
                Icon(Icons.info_outline,
                    size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All historical logs and reports for this flock are preserved.',
                    style:
                        TextStyle(fontSize: 12, color: Colors.orange.shade800),
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
            onPressed: () async {
              flock.isActive = false;
              flock.retiredDate = DateTime.now();
              flock.synced = false;
              await context.read<FlockProvider>().update(flock);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${flock.name}" has been retired')),
                );
              }
            },
            child: const Text('Retire Flock'),
          ),
        ],
      ),
    );
  }

  void _reactivate(BuildContext context, Flock flock) async {
    flock.isActive = true;
    flock.retiredDate = null;
    flock.synced = false;
    await context.read<FlockProvider>().update(flock);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${flock.name}" reactivated')),
      );
    }
  }

  void _recordMortality(BuildContext context, Flock flock) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mortality — ${flock.name}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Active birds: ${flock.activeBirds}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
                labelText: 'Number of birds that died',
                prefixIcon: Icon(Icons.remove_circle_outline)),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              final n = int.tryParse(ctrl.text) ?? 0;
              if (n > 0) {
                context.read<FlockProvider>().addMortality(flock.id, n);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ---- Section Header ----
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}

// ---- Flock Card ----
class _FlockCard extends StatelessWidget {
  final Flock flock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMortality;
  final VoidCallback? onRetire;
  final VoidCallback? onReactivate;

  const _FlockCard({
    required this.flock,
    required this.onEdit,
    required this.onDelete,
    required this.onMortality,
    required this.onRetire,
    required this.onReactivate,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header row
            Row(children: [
              Expanded(
                child: Text(flock.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis),
              ),
              if (!flock.isActive)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.archive_outlined,
                        size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('Retired',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 11)),
                  ]),
                ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                  if (v == 'mortality') onMortality?.call();
                  if (v == 'retire') onRetire?.call();
                  if (v == 'reactivate') onReactivate?.call();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                          dense: true,
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'))),
                  if (onMortality != null)
                    const PopupMenuItem(
                        value: 'mortality',
                        child: ListTile(
                            dense: true,
                            leading: Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            title: Text('Record Mortality'))),
                  if (onRetire != null)
                    PopupMenuItem(
                        value: 'retire',
                        child: ListTile(
                            dense: true,
                            leading: Icon(Icons.archive_outlined,
                                color: Colors.orange.shade700),
                            title: Text('Retire Flock',
                                style:
                                    TextStyle(color: Colors.orange.shade700)))),
                  if (onReactivate != null)
                    const PopupMenuItem(
                        value: 'reactivate',
                        child: ListTile(
                            dense: true,
                            leading: Icon(Icons.play_circle_outline,
                                color: AppTheme.primary),
                            title: Text('Reactivate',
                                style: TextStyle(color: AppTheme.primary)))),
                  const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                          dense: true,
                          leading:
                              Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red)))),
                ],
              ),
            ]),

            const SizedBox(height: 12),

            // Stats row
            Row(children: [
              _Stat('Total Birds', '${flock.numberOfBirds}'),
              _Stat('Active Birds', '${flock.activeBirds}'),
              _Stat('Mortality', '${flock.mortalityCount}'),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _Stat('Cost/Bird', formatMoney(flock.costPerBird)),
              _Stat('Started', formatDateShort(flock.startDate)),
              if (flock.retiredDate != null)
                _Stat('Retired', formatDateShort(flock.retiredDate!))
              else
                const Expanded(child: SizedBox()),
            ]),

            if (flock.notes != null && flock.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(flock.notes!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2),
            ],

            // Retire CTA only for active flocks
            if (flock.isActive) ...[
              const SizedBox(height: 14),
              const Divider(height: 0),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onRetire,
                    icon: const Icon(Icons.archive_outlined, size: 16),
                    label: const Text('Retire This Batch'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onMortality,
                    icon: const Icon(Icons.remove_circle_outline, size: 16),
                    label: const Text('Record Death'),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      );
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

class _Empty extends StatelessWidget {
  final VoidCallback onAdd;
  const _Empty({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.groups_outlined, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No flocks yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add your first flock to start tracking eggs.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500)),
        ]),
      ));
}

// ---- Flock Form ----
class FlockFormScreen extends StatefulWidget {
  final Flock? existing;
  const FlockFormScreen({super.key, this.existing});
  @override
  State<FlockFormScreen> createState() => _FlockFormScreenState();
}

class _FlockFormScreenState extends State<FlockFormScreen> {
  final _nameCtrl = TextEditingController();
  final _birdsCtrl = TextEditingController();
  final _costPerBirdCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = widget.existing;
    if (f != null) {
      _nameCtrl.text = f.name;
      _birdsCtrl.text = f.numberOfBirds.toString();
      _costPerBirdCtrl.text = f.costPerBird.toStringAsFixed(0);
      _notesCtrl.text = f.notes ?? '';
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Flock name required')));
      return;
    }
    final flock = Flock(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      numberOfBirds: int.tryParse(_birdsCtrl.text) ?? 0,
      costPerBird: double.tryParse(_costPerBirdCtrl.text) ?? 0,
      startDate: widget.existing?.startDate ?? DateTime.now(),
      isActive: widget.existing?.isActive ?? true,
      mortalityCount: widget.existing?.mortalityCount ?? 0,
      retiredDate: widget.existing?.retiredDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    final p = context.read<FlockProvider>();
    if (widget.existing != null) {
      await p.update(flock);
    } else {
      await p.add(flock);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(widget.existing != null ? 'Edit Flock' : 'Add Flock')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Flock Name *',
                hintText: 'e.g. Batch A',
                prefixIcon: Icon(Icons.groups_outlined)),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: TextField(
              controller: _birdsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Number of Birds', hintText: '100'),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
              controller: _costPerBirdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Cost per Bird (₦)', hintText: '1500'),
            )),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note_outlined)),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child:
                  Text(widget.existing != null ? 'Save Changes' : 'Add Flock'),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      );
}

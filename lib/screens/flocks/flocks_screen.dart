// lib/screens/flocks/flocks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/flock_provider.dart';
import '../../models/flock.dart';
import '../../core/app_theme.dart';
import '../../utils/formatters.dart';

class FlocksScreen extends StatelessWidget {
  const FlocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flocks = context.watch<FlockProvider>().all;
    return Scaffold(
      appBar: AppBar(title: const Text('Flocks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Flock'),
      ),
      body: flocks.isEmpty
          ? _Empty(onAdd: () => _openForm(context, null))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: flocks.length,
              itemBuilder: (_, i) => _FlockCard(
                flock: flocks[i],
                onEdit: () => _openForm(context, flocks[i]),
                onDelete: () => _confirmDelete(context, flocks[i]),
                onMortality: () => _recordMortality(context, flocks[i]),
              ),
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
                  'Delete "${flock.name}"? Daily logs linked to it will remain.'),
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
            ));
  }

  void _recordMortality(BuildContext context, Flock flock) {
    final ctrl = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Mortality — ${flock.name}'),
              content: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: 'Number of birds that died')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final n = int.tryParse(ctrl.text) ?? 0;
                    if (n > 0)
                      context.read<FlockProvider>().addMortality(flock.id, n);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ));
  }
}

class _FlockCard extends StatelessWidget {
  final Flock flock;
  final VoidCallback onEdit, onDelete, onMortality;
  const _FlockCard(
      {required this.flock,
      required this.onEdit,
      required this.onDelete,
      required this.onMortality});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(flock.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17))),
            if (!flock.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Inactive',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
                if (v == 'mortality') onMortality();
                if (v == 'toggle') {
                  flock.isActive = !flock.isActive;
                  context.read<FlockProvider>().update(flock);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                        dense: true,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'))),
                const PopupMenuItem(
                    value: 'mortality',
                    child: ListTile(
                        dense: true,
                        leading: Icon(Icons.remove_circle_outline),
                        title: Text('Record Mortality'))),
                PopupMenuItem(
                    value: 'toggle',
                    child: ListTile(
                        dense: true,
                        leading: Icon(flock.isActive
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline),
                        title: Text(
                            flock.isActive ? 'Mark Inactive' : 'Mark Active'))),
                const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                        dense: true,
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text('Delete',
                            style: TextStyle(color: Colors.red)))),
              ],
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _Stat('Total Birds', '${flock.numberOfBirds}'),
            _Stat('Active Birds', '${flock.activeBirds}'),
            _Stat('Mortality', '${flock.mortalityCount}'),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _Stat('Cost/Bird', formatMoney(flock.costPerBird)),
            _Stat('Started', formatDateShort(flock.startDate)),
          ]),
          if (flock.notes != null && flock.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(flock.notes!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]));
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
          Text('Add your first flock to start tracking eggs and mortality.',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing != null ? 'Edit Flock' : 'Add Flock')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Flock Name *',
                hintText: 'e.g. Batch A',
                prefixIcon: Icon(Icons.groups_outlined))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: _birdsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Number of Birds', hintText: '100'))),
          const SizedBox(width: 12),
          Expanded(
              child: TextField(
                  controller: _costPerBirdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Cost per Bird (₦)', hintText: '1500'))),
        ]),
        const SizedBox(height: 14),
        TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note_outlined))),
        const SizedBox(height: 28),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _save,
                child: Text(
                    widget.existing != null ? 'Save Changes' : 'Add Flock'))),
        const SizedBox(height: 40),
      ]),
    );
  }
}

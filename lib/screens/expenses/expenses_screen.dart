// lib/screens/expenses/expenses_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/expense_provider.dart';
import '../../providers/flock_provider.dart';
import '../../models/expense.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../utils/formatters.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().all;
    final filtered = _filterCategory == null
        ? expenses
        : expenses.where((e) => e.category == _filterCategory).toList();

    final totalAll = expenses.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: Column(children: [
        // Total + category filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(children: [
                Icon(Icons.receipt_long, size: 16, color: Colors.red.shade600),
                const SizedBox(width: 6),
                Text('Total: ${formatMoney(totalAll)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700)),
              ]),
            ),
          ]),
        ),

        // Category chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _chip('All', null),
              ...AppConstants.expenseCategories.map((c) => _chip(c, c)),
            ],
          ),
        ),

        // Expense list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('No expenses yet',
                      style: TextStyle(color: Colors.grey.shade500)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ExpenseTile(
                    expense: filtered[i],
                    onTap: () => _openForm(context, filtered[i]),
                    onDelete: () =>
                        context.read<ExpenseProvider>().delete(filtered[i]),
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _chip(String label, String? value) {
    final selected = _filterCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filterCategory = value),
        selectedColor: AppTheme.primary.withOpacity(0.15),
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : Colors.grey.shade700,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  void _openForm(BuildContext context, Expense? expense) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ExpenseFormScreen(existing: expense)));
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _ExpenseTile(
      {required this.expense, required this.onTap, required this.onDelete});

  static const _icons = {
    'Feed': Icons.grain,
    'Medication': Icons.medication_outlined,
    'Fuel': Icons.local_gas_station_outlined,
    'Salary': Icons.people_outlined,
    'Crates': Icons.inventory_outlined,
    'Repairs': Icons.build_outlined,
    'Other': Icons.more_horiz,
  };

  static const _colors = {
    'Feed': Colors.brown,
    'Medication': Colors.blue,
    'Fuel': Colors.deepOrange,
    'Salary': Colors.purple,
    'Crates': Colors.teal,
    'Repairs': Colors.indigo,
    'Other': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[expense.category] ?? Colors.grey;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: (color as Color).withOpacity(0.1),
          child: Icon(_icons[expense.category] ?? Icons.circle,
              color: color, size: 18),
        ),
        title: Text(expense.category,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${formatDate(expense.date)}${expense.description != null ? ' · ${expense.description}' : ''}',
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(formatMoney(expense.amount),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                  fontSize: 14)),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            onPressed: () => _confirmDelete(context),
          ),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Delete Expense?'),
              content: Text(
                  'Delete this ${expense.category} expense of ${formatMoney(expense.amount)}?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    onDelete();
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ));
  }
}

// ---- Expense Form ----
class ExpenseFormScreen extends StatefulWidget {
  final Expense? existing;
  const ExpenseFormScreen({super.key, this.existing});
  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String _category = AppConstants.expenseCategories.first;
  String? _flockId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _amountCtrl.text = e.amount.toStringAsFixed(0);
      _descCtrl.text = e.description ?? '';
      _date = e.date;
      _category = e.category;
      _flockId = e.flockId;
    }
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
    if (p != null) setState(() => _date = p);
  }

  Future<void> _save() async {
    if (_amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter an amount')));
      return;
    }
    final expense = Expense(
      id: widget.existing?.id ?? const Uuid().v4(),
      date: _date,
      category: _category,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      flockId: _flockId,
    );
    final p = context.read<ExpenseProvider>();
    if (widget.existing != null) {
      await p.update(expense);
    } else {
      await p.add(expense);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final flocks = context.watch<FlockProvider>().active;

    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.existing != null ? 'Edit Expense' : 'Add Expense')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Category selector
          const Text('Category',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.expenseCategories.map((cat) {
              final selected = _category == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) => setState(() => _category = cat),
                selectedColor: AppTheme.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: selected ? AppTheme.primary : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Date
          InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined)),
                child: Text(formatDate(_date)),
              )),
          const SizedBox(height: 14),

          // Amount
          TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₦)',
                prefixIcon: Icon(Icons.payments_outlined),
                hintText: 'e.g. 5500',
              )),
          const SizedBox(height: 14),

          // Description
          TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.note_outlined),
                hintText: 'e.g. 2 bags of layer mash',
              )),
          const SizedBox(height: 14),

          // Flock (optional)
          if (flocks.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _flockId,
              decoration: const InputDecoration(
                  labelText: 'Flock (optional)',
                  prefixIcon: Icon(Icons.groups_outlined)),
              hint: const Text('All flocks / general'),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('All flocks / general')),
                ...flocks.map(
                    (f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
              ],
              onChanged: (v) => setState(() => _flockId = v),
            ),

          const SizedBox(height: 28),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _save,
                  child: Text(widget.existing != null
                      ? 'Save Changes'
                      : 'Add Expense'))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

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
  DateTime _month = DateTime.now();
  String? _filterCategory;

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
    'Feed': Color(0xFF795548),
    'Medication': Color(0xFF1565C0),
    'Fuel': Color(0xFFE65100),
    'Salary': Color(0xFF6A1B9A),
    'Crates': Color(0xFF00695C),
    'Repairs': Color(0xFF283593),
    'Other': Color(0xFF546E7A),
  };

  void _prev() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

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
    final all = context.watch<ExpenseProvider>().all;
    final month =
        context.read<ExpenseProvider>().forMonth(_month.year, _month.month);
    final filtered = _filterCategory == null
        ? month
        : month.where((e) => e.category == _filterCategory).toList();
    final monthTotal = month.fold(0.0, (s, e) => s + e.amount);
    final allTotal = all.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'expenses_fab',
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ExpenseFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: Column(children: [
        // Month selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            IconButton(
              onPressed: _prev,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
                child: Column(children: [
              Text(formatMonthYear(_month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(formatMoney(monthTotal),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w600)),
            ])),
            IconButton(
              onPressed: _isCurrentMonth ? null : _next,
              icon: Icon(Icons.chevron_right,
                  color: _isCurrentMonth ? Colors.grey.shade300 : null),
            ),
          ]),
        ),
        const Divider(height: 0),

        // All-time total
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(children: [
            Icon(Icons.receipt_long, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Expanded(
                child: Text('All time total',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500))),
            Text(formatMoney(allTotal),
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600)),
          ]),
        ),

        // Category filter chips
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _chip('All', null),
              ...AppConstants.expenseCategories.map((c) => _chip(c, c)),
            ],
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _filterCategory == null
                              ? 'No expenses for ${formatMonthYear(_month)}'
                              : 'No $_filterCategory expenses this month',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ]),
                ))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ExpenseTile(
                    expense: filtered[i],
                    icon: _icons[filtered[i].category] ?? Icons.circle,
                    color: _colors[filtered[i].category] ?? Colors.grey,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ExpenseFormScreen(existing: filtered[i]))),
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
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(() => _filterCategory = value),
        selectedColor: AppTheme.primary.withOpacity(0.15),
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : Colors.grey.shade700,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final IconData icon;
  final Color color;
  final VoidCallback onTap, onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(expense.category,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${formatDate(expense.date)}'
            '${expense.description != null ? ' · ${expense.description}' : ''}',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(formatMoney(expense.amount),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                    fontSize: 13)),
            const SizedBox(width: 4),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              onPressed: () => _confirmDelete(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
        ),
      );

  void _confirmDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Delete Expense?'),
              content: Text('Delete this ${expense.category} expense of '
                  '${formatMoney(expense.amount)}?'),
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
      body: ListView(padding: const EdgeInsets.all(16), children: [
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
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today_outlined)),
            child: Text(formatDate(_date)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Amount (₦)',
                prefixIcon: Icon(Icons.payments_outlined),
                hintText: 'e.g. 5500')),
        const SizedBox(height: 14),
        TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.note_outlined),
                hintText: 'e.g. 2 bags of layer mash')),
        const SizedBox(height: 14),
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
                child: Text(
                    widget.existing != null ? 'Save Changes' : 'Add Expense'))),
        const SizedBox(height: 40),
      ]),
    );
  }
}

// lib/models/expense.dart
import 'package:hive/hive.dart';
import '../core/constants.dart';
part 'expense.g.dart';

@HiveType(typeId: AppConstants.expenseTypeId)
class Expense extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) DateTime date;
  @HiveField(2) String category;
  @HiveField(3) double amount;
  @HiveField(4) String? description;
  @HiveField(5) String? flockId;
  @HiveField(6) bool synced;

  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    this.description,
    this.flockId,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'date': date.toIso8601String(),
    'category': category, 'amount': amount,
    'description': description, 'flockId': flockId,
  };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    id: j['id'], date: DateTime.parse(j['date']),
    category: j['category'] ?? 'Other',
    amount: (j['amount'] ?? 0).toDouble(),
    description: j['description'],
    flockId: j['flockId'],
    synced: true,
  );
}

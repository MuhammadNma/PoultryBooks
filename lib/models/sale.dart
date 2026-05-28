// lib/models/sale.dart
import 'package:hive/hive.dart';
import '../core/constants.dart';
part 'sale.g.dart';

@HiveType(typeId: AppConstants.saleTypeId)
class Sale extends HiveObject {
  @HiveField(0)  final String id;
  @HiveField(1)  final DateTime date;
  @HiveField(2)  final String customerId;
  @HiveField(3)  final String customerName;
  @HiveField(4)  final int crates;
  @HiveField(5)  final int loosePieces;
  @HiveField(6)  final double pricePerCrate;
  @HiveField(7)  double amountPaid;
  @HiveField(8)  String? flockId;
  @HiveField(9)  String? notes;
  @HiveField(10) bool synced;

  Sale({
    required this.id, required this.date,
    required this.customerId, required this.customerName,
    required this.crates, required this.loosePieces,
    required this.pricePerCrate, required this.amountPaid,
    this.flockId, this.notes, this.synced = false,
  });

  double get totalEggIncome {
    final perEgg = pricePerCrate / AppConstants.eggsPerCrate;
    return (crates * pricePerCrate) + (loosePieces * perEgg);
  }
  double get amountOwed => (totalEggIncome - amountPaid).clamp(0, double.infinity);
  int    get totalEggs  => (crates * AppConstants.eggsPerCrate) + loosePieces;

  Map<String, dynamic> toJson() => {
    'id': id, 'date': date.toIso8601String(),
    'customerId': customerId, 'customerName': customerName,
    'crates': crates, 'loosePieces': loosePieces,
    'pricePerCrate': pricePerCrate, 'amountPaid': amountPaid,
    'flockId': flockId, 'notes': notes,
  };

  factory Sale.fromJson(Map<String, dynamic> j) => Sale(
    id: j['id'], date: DateTime.parse(j['date']),
    customerId: j['customerId'], customerName: j['customerName'] ?? '',
    crates: (j['crates'] ?? 0) as int, loosePieces: (j['loosePieces'] ?? 0) as int,
    pricePerCrate: (j['pricePerCrate'] ?? 0).toDouble(),
    amountPaid: (j['amountPaid'] ?? 0).toDouble(),
    flockId: j['flockId'], notes: j['notes'], synced: true,
  );
}

import 'package:hive/hive.dart';
part 'customer_transaction.g.dart';

@HiveType(typeId: 1)
class CustomerTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  int crates;

  @HiveField(3)
  int pieces;

  @HiveField(4)
  double pricePerCrate;

  @HiveField(5)
  double totalAmount;

  @HiveField(6)
  double amountPaid;

  @HiveField(7)
  DateTime date;

  CustomerTransaction({
    required this.id,
    required this.customerId,
    required this.crates,
    required this.pieces,
    required this.pricePerCrate,
    required this.totalAmount,
    required this.amountPaid,
    required this.date,
  });

/// 🔁 JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'crates': crates,
        'pieces': pieces,
        'pricePerCrate': pricePerCrate,
        'totalAmount': totalAmount,
        'amountPaid': amountPaid,
        'date': date.toIso8601String(),
      };

  factory CustomerTransaction.fromJson(Map<String, dynamic> json) =>
      CustomerTransaction(
        id: json['id'],
        customerId: json['customerId'],
        crates: json['crates'],
        pieces: json['pieces'],
        pricePerCrate: (json['pricePerCrate'] ?? 0).toDouble(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        amountPaid: (json['amountPaid'] ?? 0).toDouble(),
        date: DateTime.parse(json['date']),
      );

}

import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  double totalSpent;

  @HiveField(5)
  double totalPaid;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.totalSpent = 0.0,
    this.totalPaid = 0.0,
  });

  double get owing {
    final diff = totalSpent - totalPaid;
    return diff > 0 ? diff : 0;
  }

  double get balance => totalPaid - totalSpent;

  /// 🔁 JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'totalSpent': totalSpent,
        'totalPaid': totalPaid,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        address: json['address'],
        totalSpent: (json['totalSpent'] ?? 0).toDouble(),
        totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      );
}

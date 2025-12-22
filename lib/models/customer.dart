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
}

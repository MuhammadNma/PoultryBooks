// lib/models/customer.dart
import 'package:hive/hive.dart';
import '../core/constants.dart';
part 'customer.g.dart';

@HiveType(typeId: AppConstants.customerTypeId)
class Customer extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) String name;
  @HiveField(2) String phone;
  @HiveField(3) String? address;
  @HiveField(4) bool synced;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'address': address,
  };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
    id: j['id'], name: j['name'], phone: j['phone'],
    address: j['address'], synced: true,
  );
}

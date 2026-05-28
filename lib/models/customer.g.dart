// lib/models/customer.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'customer.dart';

class CustomerAdapter extends TypeAdapter<Customer> {
  @override final int typeId = 4;

  @override
  Customer read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Customer(
      id: f[0] as String,
      name: f[1] as String,
      phone: f[2] as String,
      address: f[3] as String?,
      synced: (f[4] ?? false) as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.phone)
      ..writeByte(3)..write(obj.address)
      ..writeByte(4)..write(obj.synced);
  }

  @override bool operator ==(Object o) => o is CustomerAdapter && o.typeId == typeId;
  @override int get hashCode => typeId.hashCode;
}

// lib/models/sale.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'sale.dart';

class SaleAdapter extends TypeAdapter<Sale> {
  @override final int typeId = 2;

  @override
  Sale read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Sale(
      id: f[0] as String, date: f[1] as DateTime,
      customerId: f[2] as String, customerName: (f[3] ?? '') as String,
      crates: (f[4] ?? 0) as int, loosePieces: (f[5] ?? 0) as int,
      pricePerCrate: (f[6] ?? 0.0) as double,
      amountPaid: (f[7] ?? 0.0) as double,
      flockId: f[8] as String?, notes: f[9] as String?,
      synced: (f[10] ?? false) as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.date)
      ..writeByte(2)..write(obj.customerId)
      ..writeByte(3)..write(obj.customerName)
      ..writeByte(4)..write(obj.crates)
      ..writeByte(5)..write(obj.loosePieces)
      ..writeByte(6)..write(obj.pricePerCrate)
      ..writeByte(7)..write(obj.amountPaid)
      ..writeByte(8)..write(obj.flockId)
      ..writeByte(9)..write(obj.notes)
      ..writeByte(10)..write(obj.synced);
  }

  @override bool operator ==(Object o) => o is SaleAdapter && o.typeId == typeId;
  @override int get hashCode => typeId.hashCode;
}

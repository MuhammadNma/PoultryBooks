// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 2;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      customerId: fields[2] as String,
      customerName: fields[3] as String,
      crates: fields[4] as int,
      loosePieces: fields[5] as int,
      pricePerCrate: fields[6] as double,
      amountPaid: fields[7] as double,
      flockId: fields[8] as String?,
      notes: fields[9] as String?,
      synced: fields[10] as bool,
      isGift: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.customerName)
      ..writeByte(4)
      ..write(obj.crates)
      ..writeByte(5)
      ..write(obj.loosePieces)
      ..writeByte(6)
      ..write(obj.pricePerCrate)
      ..writeByte(7)
      ..write(obj.amountPaid)
      ..writeByte(8)
      ..write(obj.flockId)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.synced)
      ..writeByte(11)
      ..write(obj.isGift);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

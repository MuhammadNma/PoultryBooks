// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerTransactionAdapter extends TypeAdapter<CustomerTransaction> {
  @override
  final int typeId = 1;

  @override
  CustomerTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerTransaction(
      id: fields[0] as String,
      customerId: fields[1] as String,
      crates: fields[2] as int,
      pieces: fields[3] as int,
      pricePerCrate: fields[4] as double,
      totalAmount: fields[5] as double,
      amountPaid: fields[6] as double,
      date: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerTransaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.crates)
      ..writeByte(3)
      ..write(obj.pieces)
      ..writeByte(4)
      ..write(obj.pricePerCrate)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.amountPaid)
      ..writeByte(7)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

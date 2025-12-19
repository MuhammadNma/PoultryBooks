// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profit_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfitRecordAdapter extends TypeAdapter<ProfitRecord> {
  @override
  final int typeId = 2;

  @override
  ProfitRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfitRecord(
      date: fields[0] as DateTime,
      profit: fields[1] as double,
      eggIncome: fields[2] as double,
      feedCost: fields[3] as double,
      fixedCostPerDay: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ProfitRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.profit)
      ..writeByte(2)
      ..write(obj.eggIncome)
      ..writeByte(3)
      ..write(obj.feedCost)
      ..writeByte(4)
      ..write(obj.fixedCostPerDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfitRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

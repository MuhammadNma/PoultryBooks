// lib/models/egg_adjustment.g.dart
// HAND-WRITTEN ADAPTER — no build_runner needed for this file.
// If you later regenerate with build_runner, delete this file first
// so it can be replaced automatically.

part of 'egg_adjustment.dart';

class EggAdjustmentAdapter extends TypeAdapter<EggAdjustment> {
  @override
  final int typeId = 5;

  @override
  EggAdjustment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EggAdjustment(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      eggs: fields[2] as int,
      typeStr: fields[3] as String,
      reason: fields[4] as String,
      synced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EggAdjustment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.eggs)
      ..writeByte(3)
      ..write(obj.typeStr)
      ..writeByte(4)
      ..write(obj.reason)
      ..writeByte(5)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EggAdjustmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

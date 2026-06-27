// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlockAdapter extends TypeAdapter<Flock> {
  @override
  final int typeId = 0;

  @override
  Flock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flock(
      id: fields[0] as String,
      name: fields[1] as String,
      numberOfBirds: fields[2] as int,
      costPerBird: fields[3] as double,
      startDate: fields[4] as DateTime,
      isActive: fields[5] as bool,
      mortalityCount: fields[6] as int,
      notes: fields[7] as String?,
      retiredDate: fields[8] as DateTime?,
      synced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Flock obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.numberOfBirds)
      ..writeByte(3)
      ..write(obj.costPerBird)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.mortalityCount)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.retiredDate)
      ..writeByte(9)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

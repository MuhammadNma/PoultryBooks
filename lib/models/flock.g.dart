// lib/models/flock.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'flock.dart';

class FlockAdapter extends TypeAdapter<Flock> {
  @override final int typeId = 0;

  @override
  Flock read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read()
    };
    return Flock(
      id: f[0] as String,
      name: f[1] as String,
      numberOfBirds: (f[2] ?? 0) as int,
      costPerBird: (f[3] ?? 0.0) as double,
      startDate: f[4] as DateTime,
      isActive: f[5] == null ? true : f[5] as bool,
      mortalityCount: (f[6] ?? 0) as int,
      notes: f[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Flock obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.numberOfBirds)
      ..writeByte(3)..write(obj.costPerBird)
      ..writeByte(4)..write(obj.startDate)
      ..writeByte(5)..write(obj.isActive)
      ..writeByte(6)..write(obj.mortalityCount)
      ..writeByte(7)..write(obj.notes);
  }

  @override bool operator ==(Object o) =>
      o is FlockAdapter && o.typeId == typeId;
  @override int get hashCode => typeId.hashCode;
}

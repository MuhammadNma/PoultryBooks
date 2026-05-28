// // lib/models/flock.g.dart
// // GENERATED CODE - DO NOT MODIFY BY HAND
// // Run: flutter pub run build_runner build

// part of 'flock.dart';

// class FlockAdapter extends TypeAdapter<Flock> {
//   @override
//   final int typeId = 3;

//   @override
//   Flock read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return Flock(
//       id: fields[0] as String,
//       name: fields[1] as String,
//       type: fields[2] as String,
//       numberOfBirds: fields[3] as int,
//       costPerBird: fields[4] as double,
//       startDate: fields[5] as DateTime,
//       layingPeriodDays: fields[6] as int,
//       housingCost: fields[7] as double,
//       housingLifespanDays: fields[8] as int,
//       equipmentCost: fields[9] as double,
//       equipmentLifespanDays: fields[10] as int,
//       isActive: fields[11] as bool,
//       mortalityCount: fields[12] as int,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, Flock obj) {
//     writer
//       ..writeByte(13)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.name)
//       ..writeByte(2)
//       ..write(obj.type)
//       ..writeByte(3)
//       ..write(obj.numberOfBirds)
//       ..writeByte(4)
//       ..write(obj.costPerBird)
//       ..writeByte(5)
//       ..write(obj.startDate)
//       ..writeByte(6)
//       ..write(obj.layingPeriodDays)
//       ..writeByte(7)
//       ..write(obj.housingCost)
//       ..writeByte(8)
//       ..write(obj.housingLifespanDays)
//       ..writeByte(9)
//       ..write(obj.equipmentCost)
//       ..writeByte(10)
//       ..write(obj.equipmentLifespanDays)
//       ..writeByte(11)
//       ..write(obj.isActive)
//       ..writeByte(12)
//       ..write(obj.mortalityCount);
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FlockAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;

//   @override
//   int get hashCode => typeId.hashCode;
// }

// lib/models/flock.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'flock.dart';

class FlockAdapter extends TypeAdapter<Flock> {
  @override
  final int typeId = 0;

  @override
  Flock read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read()
    };
    return Flock(
      id: f[0] as String,
      name: f[1] as String,
      numberOfBirds: f[2] as int,
      costPerBird: f[3] as double,
      startDate: f[4] as DateTime,
      isActive: f[5] as bool,
      mortalityCount: f[6] as int,
      notes: f[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Flock obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.notes);
  }

  @override
  bool operator ==(Object o) => o is FlockAdapter && o.typeId == typeId;
  @override
  int get hashCode => typeId.hashCode;
}

// lib/models/daily_log.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'daily_log.dart';

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override final int typeId = 1;

  @override
  DailyLog read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read()
    };
    return DailyLog(
      id: f[0] as String,
      date: f[1] as DateTime,
      flockId: f[2] as String,
      eggsCollected: (f[3] ?? 0) as int,
      mortality: (f[4] ?? 0) as int,
      notes: f[5] as String?,
      synced: f[6] == null ? false : f[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.date)
      ..writeByte(2)..write(obj.flockId)
      ..writeByte(3)..write(obj.eggsCollected)
      ..writeByte(4)..write(obj.mortality)
      ..writeByte(5)..write(obj.notes)
      ..writeByte(6)..write(obj.synced);
  }

  @override bool operator ==(Object o) =>
      o is DailyLogAdapter && o.typeId == typeId;
  @override int get hashCode => typeId.hashCode;
}

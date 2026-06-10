// lib/models/expense.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'expense.dart';

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override final int typeId = 3;

  @override
  Expense read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read()
    };
    return Expense(
      id: f[0] as String,
      date: f[1] as DateTime,
      category: (f[2] ?? 'Other') as String,
      amount: (f[3] ?? 0.0) as double,
      description: f[4] as String?,
      flockId: f[5] as String?,
      synced: f[6] == null ? false : f[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.date)
      ..writeByte(2)..write(obj.category)
      ..writeByte(3)..write(obj.amount)
      ..writeByte(4)..write(obj.description)
      ..writeByte(5)..write(obj.flockId)
      ..writeByte(6)..write(obj.synced);
  }

  @override bool operator ==(Object o) =>
      o is ExpenseAdapter && o.typeId == typeId;
  @override int get hashCode => typeId.hashCode;
}

// lib/models/daily_log.dart
import 'package:hive/hive.dart';
import '../core/constants.dart';
part 'daily_log.g.dart';

@HiveType(typeId: AppConstants.dailyLogTypeId)
class DailyLog extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final DateTime date;
  @HiveField(2) final String flockId;
  @HiveField(3) int eggsCollected;
  @HiveField(4) int mortality;
  @HiveField(5) String? notes;
  @HiveField(6) bool synced;

  DailyLog({
    required this.id,
    required this.date,
    required this.flockId,
    required this.eggsCollected,
    this.mortality = 0,
    this.notes,
    this.synced = false,
  });

  int get cratesProduced => eggsCollected ~/ AppConstants.eggsPerCrate;
  int get looseEggs      => eggsCollected %  AppConstants.eggsPerCrate;

  Map<String, dynamic> toJson() => {
    'id': id, 'date': date.toIso8601String(), 'flockId': flockId,
    'eggsCollected': eggsCollected, 'mortality': mortality, 'notes': notes,
  };

  factory DailyLog.fromJson(Map<String, dynamic> j) => DailyLog(
    id: j['id'], date: DateTime.parse(j['date']),
    flockId: j['flockId'],
    eggsCollected: (j['eggsCollected'] ?? 0) as int,
    mortality: (j['mortality'] ?? 0) as int,
    notes: j['notes'],
    synced: true,
  );
}

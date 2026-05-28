// lib/models/flock.dart
import 'package:hive/hive.dart';
import '../core/constants.dart';
part 'flock.g.dart';

@HiveType(typeId: AppConstants.flockTypeId)
class Flock extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) String name;
  @HiveField(2) int numberOfBirds;
  @HiveField(3) double costPerBird;
  @HiveField(4) final DateTime startDate;
  @HiveField(5) bool isActive;
  @HiveField(6) int mortalityCount;
  @HiveField(7) String? notes;

  Flock({
    required this.id,
    required this.name,
    required this.numberOfBirds,
    required this.costPerBird,
    required this.startDate,
    this.isActive = true,
    this.mortalityCount = 0,
    this.notes,
  });

  int get activeBirds => numberOfBirds - mortalityCount;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name,
    'numberOfBirds': numberOfBirds, 'costPerBird': costPerBird,
    'startDate': startDate.toIso8601String(),
    'isActive': isActive, 'mortalityCount': mortalityCount, 'notes': notes,
  };

  factory Flock.fromJson(Map<String, dynamic> j) => Flock(
    id: j['id'], name: j['name'],
    numberOfBirds: j['numberOfBirds'] ?? 0,
    costPerBird: (j['costPerBird'] ?? 0).toDouble(),
    startDate: DateTime.parse(j['startDate']),
    isActive: j['isActive'] ?? true,
    mortalityCount: j['mortalityCount'] ?? 0,
    notes: j['notes'],
  );
}

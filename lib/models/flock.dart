// lib/models/flock.dart
import 'package:hive/hive.dart';
import '../core/constants.dart';
part 'flock.g.dart';

@HiveType(typeId: AppConstants.flockTypeId)
class Flock extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int numberOfBirds;
  @HiveField(3)
  double costPerBird;
  @HiveField(4)
  final DateTime startDate;
  @HiveField(5)
  bool isActive;
  @HiveField(6)
  int mortalityCount;
  @HiveField(7)
  String? notes;
  // Fields 8 & 9 are new — run `dart run build_runner build` after adding
  @HiveField(8)
  DateTime? retiredDate;
  @HiveField(9)
  bool synced;

  Flock({
    required this.id,
    required this.name,
    required this.numberOfBirds,
    required this.costPerBird,
    required this.startDate,
    this.isActive = true,
    this.mortalityCount = 0,
    this.notes,
    this.retiredDate,
    this.synced = false,
  });

  int get activeBirds =>
      (numberOfBirds - mortalityCount).clamp(0, numberOfBirds);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'numberOfBirds': numberOfBirds,
        'costPerBird': costPerBird,
        'startDate': startDate.toIso8601String(),
        'isActive': isActive,
        'mortalityCount': mortalityCount,
        'notes': notes,
        'retiredDate': retiredDate?.toIso8601String(),
      };

  factory Flock.fromJson(Map<String, dynamic> j) => Flock(
        id: j['id'],
        name: j['name'],
        numberOfBirds: j['numberOfBirds'] ?? 0,
        costPerBird: (j['costPerBird'] ?? 0).toDouble(),
        startDate: DateTime.parse(j['startDate']),
        isActive: j['isActive'] ?? true,
        mortalityCount: j['mortalityCount'] ?? 0,
        notes: j['notes'],
        retiredDate:
            j['retiredDate'] != null ? DateTime.parse(j['retiredDate']) : null,
        synced: true,
      );
}

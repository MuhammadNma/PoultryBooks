// lib/models/egg_adjustment.dart
import 'package:hive/hive.dart';
import '../core/constants.dart';
part 'egg_adjustment.g.dart';

enum AdjustmentType { loss, stockCorrection }

@HiveType(typeId: AppConstants.eggAdjustmentTypeId)
class EggAdjustment extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final int eggs; // always positive; sign determined by type
  @HiveField(3)
  final String typeStr; // 'loss' or 'stockCorrection'
  @HiveField(4)
  final String reason;
  @HiveField(5)
  bool synced;

  EggAdjustment({
    required this.id,
    required this.date,
    required this.eggs,
    required this.typeStr,
    required this.reason,
    this.synced = false,
  });

  AdjustmentType get type =>
      typeStr == 'loss' ? AdjustmentType.loss : AdjustmentType.stockCorrection;

  /// How this adjustment affects the eggs-on-hand total:
  /// Loss        → negative (reduces stock)
  /// Correction  → can be positive or negative depending on context —
  ///               stored as a signed value in [eggs] for corrections.
  int get signedEffect => type == AdjustmentType.loss ? -eggs : eggs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'eggs': eggs,
        'typeStr': typeStr,
        'reason': reason,
      };

  factory EggAdjustment.fromJson(Map<String, dynamic> j) => EggAdjustment(
        id: j['id'],
        date: DateTime.parse(j['date']),
        eggs: (j['eggs'] as num).toInt(),
        typeStr: j['typeStr'],
        reason: j['reason'] ?? '',
        synced: true,
      );
}

// import 'package:poultry_profit_calculator/utils/currency.dart';

// class AppSettings {
//   final double pricePerCrate;
//   final double feedBagCost;
//   final double bagSizeKg;
//   final String? farmName; // <-- new field

//   AppSettings({
//     required this.pricePerCrate,
//     required this.feedBagCost,
//     required this.bagSizeKg,
//     this.farmName,
//   });

//   factory AppSettings.defaults() => AppSettings(
//         pricePerCrate: 0,
//         feedBagCost: 0,
//         bagSizeKg: 25,
//         farmName: 'Your Farm',
//       );

//   Map<String, dynamic> toJson() => {
//         'pricePerCrate': formatMoney(pricePerCrate),
//         'feedBagCost': formatMoney(feedBagCost),
//         'bagSizeKg': bagSizeKg,
//         'farmName': farmName ?? 'Your Farm',
//       };

//   factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
//         pricePerCrate: (json['pricePerCrate'] ?? 0).toDouble(),
//         feedBagCost: (json['feedBagCost'] ?? 0).toDouble(),
//         bagSizeKg: (json['bagSizeKg'] ?? 25).toDouble(),
//         farmName: json['farmName'],
//       );

//   AppSettings copyWith({
//     double? pricePerCrate,
//     double? feedBagCost,
//     double? bagSizeKg,
//     String? farmName,
//   }) =>
//       AppSettings(
//         pricePerCrate: pricePerCrate ?? this.pricePerCrate,
//         feedBagCost: feedBagCost ?? this.feedBagCost,
//         bagSizeKg: bagSizeKg ?? this.bagSizeKg,
//         farmName: farmName ?? this.farmName,
//       );
// }

class AppSettings {
  final double pricePerCrate;
  final double feedBagCost;
  final double bagSizeKg;
  final String farmName;

  const AppSettings({
    required this.pricePerCrate,
    required this.feedBagCost,
    required this.bagSizeKg,
    required this.farmName,
  });

  /* ---------------- DEFAULTS ---------------- */

  factory AppSettings.defaults() => const AppSettings(
        pricePerCrate: 0,
        feedBagCost: 0,
        bagSizeKg: 25,
        farmName: 'Your Farm',
      );

  /* ---------------- JSON ---------------- */

  Map<String, dynamic> toJson() => {
        // ✅ STORE RAW NUMBERS
        'pricePerCrate': pricePerCrate,
        'feedBagCost': feedBagCost,
        'bagSizeKg': bagSizeKg,
        'farmName': farmName,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      pricePerCrate: (json['pricePerCrate'] ?? 0).toDouble(),
      feedBagCost: (json['feedBagCost'] ?? 0).toDouble(),
      bagSizeKg: (json['bagSizeKg'] ?? 25).toDouble(),
      farmName: json['farmName'] ?? 'Your Farm',
    );
  }

  /* ---------------- COPY ---------------- */

  AppSettings copyWith({
    double? pricePerCrate,
    double? feedBagCost,
    double? bagSizeKg,
    String? farmName,
  }) {
    return AppSettings(
      pricePerCrate: pricePerCrate ?? this.pricePerCrate,
      feedBagCost: feedBagCost ?? this.feedBagCost,
      bagSizeKg: bagSizeKg ?? this.bagSizeKg,
      farmName: farmName ?? this.farmName,
    );
  }
}

// class AppSettings {
//   final double pricePerCrate;
//   final double feedBagCost;
//   final double bagSizeKg;

//   AppSettings({
//     required this.pricePerCrate,
//     required this.feedBagCost,
//     required this.bagSizeKg,
//   });

//   factory AppSettings.defaults() => AppSettings(
//         pricePerCrate: 0,
//         feedBagCost: 0,
//         bagSizeKg: 50,
//       );

//   Map<String, dynamic> toJson() => {
//         'pricePerCrate': pricePerCrate,
//         'feedBagCost': feedBagCost,
//         'bagSizeKg': bagSizeKg,
//       };

//   factory AppSettings.fromJson(Map<String, dynamic> json) {
//     return AppSettings(
//       pricePerCrate: (json['pricePerCrate'] ?? 0).toDouble(),
//       feedBagCost: (json['feedBagCost'] ?? 0).toDouble(),
//       bagSizeKg: (json['bagSizeKg'] ?? 50).toDouble(),
//     );
//   }
// }

class AppSettings {
  final double pricePerCrate;
  final double feedBagCost;
  final double bagSizeKg;
  final String? farmName; // <-- new field

  AppSettings({
    required this.pricePerCrate,
    required this.feedBagCost,
    required this.bagSizeKg,
    this.farmName,
  });

  factory AppSettings.defaults() => AppSettings(
        pricePerCrate: 0,
        feedBagCost: 0,
        bagSizeKg: 25,
        farmName: 'Your Farm',
      );

  Map<String, dynamic> toJson() => {
        'pricePerCrate': pricePerCrate,
        'feedBagCost': feedBagCost,
        'bagSizeKg': bagSizeKg,
        'farmName': farmName ?? 'Your Farm',
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        pricePerCrate: (json['pricePerCrate'] ?? 0).toDouble(),
        feedBagCost: (json['feedBagCost'] ?? 0).toDouble(),
        bagSizeKg: (json['bagSizeKg'] ?? 25).toDouble(),
        farmName: json['farmName'],
      );

  AppSettings copyWith({
    double? pricePerCrate,
    double? feedBagCost,
    double? bagSizeKg,
    String? farmName,
  }) =>
      AppSettings(
        pricePerCrate: pricePerCrate ?? this.pricePerCrate,
        feedBagCost: feedBagCost ?? this.feedBagCost,
        bagSizeKg: bagSizeKg ?? this.bagSizeKg,
        farmName: farmName ?? this.farmName,
      );
}

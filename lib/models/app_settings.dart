class AppSettings {
  final double pricePerCrate;
  final double feedBagCost;
  final double bagSizeKg;

  AppSettings({
    required this.pricePerCrate,
    required this.feedBagCost,
    required this.bagSizeKg,
  });

  factory AppSettings.defaults() => AppSettings(
        pricePerCrate: 0,
        feedBagCost: 0,
        bagSizeKg: 50,
      );

  Map<String, dynamic> toJson() => {
        'pricePerCrate': pricePerCrate,
        'feedBagCost': feedBagCost,
        'bagSizeKg': bagSizeKg,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      pricePerCrate: (json['pricePerCrate'] ?? 0).toDouble(),
      feedBagCost: (json['feedBagCost'] ?? 0).toDouble(),
      bagSizeKg: (json['bagSizeKg'] ?? 50).toDouble(),
    );
  }
}

// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

class AppSettings {
  final String farmName;
  final double defaultPricePerCrate;
  final bool onboardingComplete;

  const AppSettings({
    this.farmName = 'My Farm',
    this.defaultPricePerCrate = 0,
    this.onboardingComplete = false,
  });

  Map<String, dynamic> toJson() => {
        'farmName': farmName,
        'defaultPricePerCrate': defaultPricePerCrate,
        'onboardingComplete': onboardingComplete,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        farmName: j['farmName'] ?? 'My Farm',
        defaultPricePerCrate: (j['defaultPricePerCrate'] ?? 0).toDouble(),
        onboardingComplete: j['onboardingComplete'] ?? false,
      );

  AppSettings copyWith({
    String? farmName,
    double? defaultPricePerCrate,
    bool? onboardingComplete,
  }) =>
      AppSettings(
        farmName: farmName ?? this.farmName,
        defaultPricePerCrate: defaultPricePerCrate ?? this.defaultPricePerCrate,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
}

class SettingsProvider extends ChangeNotifier {
  static const _key = 'settings';
  Box? _box;
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;
  bool get onboardingComplete => _settings.onboardingComplete;

  Future<void> init(String uid) async {
    _box = await Hive.openBox('${AppConstants.settingsBox}$uid');
    final raw = _box!.get(_key);
    _settings = raw == null
        ? const AppSettings()
        : AppSettings.fromJson(Map<String, dynamic>.from(raw));
    notifyListeners();
  }

  Future<void> save(AppSettings s) async {
    _settings = s;
    await _box?.put(_key, s.toJson());
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String farmName,
    required double defaultPricePerCrate,
  }) =>
      save(_settings.copyWith(
        farmName: farmName,
        defaultPricePerCrate: defaultPricePerCrate,
        onboardingComplete: true,
      ));
}

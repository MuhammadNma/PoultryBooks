// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        farmName: j['farmName'] as String? ?? 'My Farm',
        defaultPricePerCrate:
            (j['defaultPricePerCrate'] as num?)?.toDouble() ?? 0,
        onboardingComplete: j['onboardingComplete'] as bool? ?? false,
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

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  AppSettings get settings => _settings;
  bool get onboardingComplete => _settings.onboardingComplete;

  DocumentReference? get _remoteDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('meta').doc('settings');
  }

  /// Called by AuthGate during app init.
  /// Loads Hive first for instant display, then AWAITS Firestore pull
  /// so that on a fresh install / new device the real settings values
  /// are available before the rest of the app renders.
  Future<void> init(String uid) async {
    _box = await Hive.openBox('${AppConstants.settingsBox}_$uid');

    // 1. Load from local Hive immediately
    final raw = _box!.get(_key);
    if (raw != null) {
      _settings = AppSettings.fromJson(Map<String, dynamic>.from(raw as Map));
    }

    // 2. Always AWAIT the Firestore pull before completing init.
    //    This is the fix — previously this was fire-and-forget so the
    //    app rendered with empty/default values on a fresh install.
    await _pullFromFirestore();

    notifyListeners();
  }

  /// Pulls settings from Firestore and applies if remote is better.
  /// Firestore wins when:
  ///   - Local Hive was empty (fresh install / reinstall)
  ///   - Remote has onboardingComplete=true but local does not
  ///     (new device login where onboarding was done on another device)
  Future<void> _pullFromFirestore() async {
    try {
      final doc = await _remoteDoc?.get();
      if (doc == null || !doc.exists) return;

      final remote = AppSettings.fromJson(doc.data() as Map<String, dynamic>);

      final localIsDefault = _settings.farmName == 'My Farm' &&
          _settings.defaultPricePerCrate == 0 &&
          !_settings.onboardingComplete;
      final remoteIsMoreComplete =
          remote.onboardingComplete && !_settings.onboardingComplete;

      if (localIsDefault || remoteIsMoreComplete) {
        _settings = remote;
        // Write back to Hive so next cold-start is instant (no Firestore needed)
        await _box?.put(_key, remote.toJson());
      }
    } catch (e) {
      // Offline or error — silently keep local Hive value
      debugPrint('Settings pull skipped: $e');
    }
  }

  /// Saves locally (instant) then pushes to Firestore in the background.
  Future<void> save(AppSettings s) async {
    _settings = s;
    await _box?.put(_key, s.toJson());
    notifyListeners();
    _pushToFirestore(s); // intentional fire-and-forget
  }

  Future<void> _pushToFirestore(AppSettings s) async {
    try {
      await _remoteDoc?.set(s.toJson());
    } catch (e) {
      debugPrint('Settings push failed: $e');
    }
  }

  Future<void> completeOnboarding({
    required String farmName,
    required double defaultPricePerCrate,
  }) =>
      save(
        _settings.copyWith(
          farmName: farmName,
          defaultPricePerCrate: defaultPricePerCrate,
          onboardingComplete: true,
        ),
      );
}

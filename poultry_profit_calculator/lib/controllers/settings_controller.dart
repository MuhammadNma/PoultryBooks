// import 'package:hive/hive.dart';
// import '../models/app_settings.dart';

// class SettingsController {
//   static const _boxName = 'settings';
//   static const _key = 'app_settings';

//   late Box _box;
//   late AppSettings _settings;

//   AppSettings get settings => _settings;

//   /* ---------------- INIT ---------------- */

//   Future<void> init() async {
//     _box = await Hive.openBox(_boxName);

//     final raw = _box.get(_key);

//     if (raw == null) {
//       _settings = AppSettings.defaults();
//       await _box.put(_key, _settings.toJson());
//     } else {
//       _settings = AppSettings.fromJson(
//         Map<String, dynamic>.from(raw),
//       );
//     }
//   }

//   /* ---------------- SAVE ---------------- */

//   Future<void> save(AppSettings newSettings) async {
//     _settings = newSettings;

//     await _box.put(
//       _key,
//       newSettings.toJson(),
//     );
//   }

//   /* ---------------- RESET ---------------- */

//   Future<void> reset() async {
//     _settings = AppSettings.defaults();
//     await _box.put(_key, _settings.toJson());
//   }
// }

import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class SettingsController {
  static const _key = 'app_settings';

  late Box _box;
  late AppSettings _settings;

  String? _currentUserId;

  AppSettings get settings => _settings;

  /* ---------------- INIT ---------------- */

  /// 🔑 Initialize per user (CALL AFTER LOGIN)
  Future<void> initForUser(String userId) async {
    if (_currentUserId == userId && Hive.isBoxOpen('settings_$userId')) {
      return;
    }

    _currentUserId = userId;

    _box = await Hive.openBox('settings_$userId');

    final raw = _box.get(_key);

    if (raw == null) {
      _settings = AppSettings.defaults();
      await _box.put(_key, _settings.toJson());
    } else {
      _settings = AppSettings.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }
  }

  // Backward compatibility method
  Future<void> init() async {
    if (_currentUserId == null) {
      throw Exception('initForUser(userId) must be called before init().');
    }
  }

  /* ---------------- SAVE ---------------- */

  Future<void> save(AppSettings newSettings) async {
    _settings = newSettings;

    await _box.put(
      _key,
      newSettings.toJson(),
    );
  }

  /* ---------------- RESET ---------------- */

  Future<void> reset() async {
    _settings = AppSettings.defaults();
    await _box.put(_key, _settings.toJson());
  }
}

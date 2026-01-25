import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class SettingsController {
  static const _boxName = 'settings';
  static const _key = 'app_settings';

  Box? _box;
  late AppSettings _settings;

  AppSettings get settings => _settings;

  Future<void> init() async {
    _box ??= await Hive.openBox(_boxName);

    final raw = _box!.get(_key);
    if (raw == null) {
      _settings = AppSettings.defaults();
      await _box!.put(_key, _settings.toJson());
    } else {
      _settings = AppSettings.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }
  }

  Future<void> save(AppSettings settings) async {
    _settings = settings;
    await _box!.put(_key, settings.toJson());
  }
}

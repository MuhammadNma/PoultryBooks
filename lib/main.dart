// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'models/flock.dart';
import 'models/daily_log.dart';
import 'models/sale.dart';
import 'models/expense.dart';
import 'models/customer.dart';
import 'providers/flock_provider.dart';
import 'providers/daily_log_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sync_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Clear all old Hive data to prevent type cast errors from old adapters
  await _clearOldHiveData();

  await Hive.initFlutter();
  Hive.registerAdapter(FlockAdapter());
  Hive.registerAdapter(DailyLogAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CustomerAdapter());

  runApp(const PoultryBooksApp());
}

/// Deletes the entire Hive storage directory on first run after upgrade.
/// Uses a version file to only do this once.
Future<void> _clearOldHiveData() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final versionFile = File('${dir.path}/pb_schema_version.txt');
    const currentVersion = '3';

    // If version file exists and matches, skip clearing
    if (versionFile.existsSync()) {
      final version = versionFile.readAsStringSync().trim();
      if (version == currentVersion) return;
    }

    // Version mismatch or first run — clear all Hive boxes
    final hivePath = dir.path;
    final hiveFiles = dir
        .listSync()
        .where((f) =>
            f.path.endsWith('.hive') || f.path.endsWith('.lock'))
        .toList();

    for (final file in hiveFiles) {
      try {
        await file.delete();
      } catch (_) {}
    }

    // Write new version
    await versionFile.writeAsString(currentVersion);
  } catch (e) {
    debugPrint('Hive cleanup error: $e');
  }
}

class PoultryBooksApp extends StatelessWidget {
  const PoultryBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlockProvider()),
        ChangeNotifierProvider(create: (_) => DailyLogProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: MaterialApp(
        title: 'PoultryBooks',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

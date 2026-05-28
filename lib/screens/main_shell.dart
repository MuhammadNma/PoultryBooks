// lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../providers/flock_provider.dart';
import '../providers/daily_log_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/customer_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'daily_log/daily_log_screen.dart';
import 'sales/sales_screen.dart';
import 'customers/customers_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  void switchTab(int index) => setState(() => _index = index);

  void triggerSync() => _sync();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncProvider>().startMonitoring();
      _sync();
    });
  }

  void _sync() => context.read<SyncProvider>().syncAll(
        flocks: context.read<FlockProvider>(),
        logs: context.read<DailyLogProvider>(),
        sales: context.read<SaleProvider>(),
        expenses: context.read<ExpenseProvider>(),
        customers: context.read<CustomerProvider>(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: const [
        DashboardScreen(),
        DailyLogScreen(),
        SalesScreen(),
        CustomersScreen(),
        SettingsScreen(),
      ]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SyncBanner(onRetry: _sync),
          BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.egg_outlined),
                  activeIcon: Icon(Icons.egg),
                  label: 'Daily Log'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.sell_outlined),
                  activeIcon: Icon(Icons.sell),
                  label: 'Sales'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_outlined),
                  activeIcon: Icon(Icons.people),
                  label: 'Customers'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _SyncBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncProvider>();
    if (sync.status == SyncStatus.syncing) {
      return Container(
        color: Colors.blue.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: const Row(children: [
          SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text('Syncing…', style: TextStyle(fontSize: 12)),
        ]),
      );
    }
    if (!sync.isOnline) {
      return Container(
        color: Colors.orange.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          Icon(Icons.wifi_off, size: 14, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Offline — changes will sync when connected',
                  style:
                      TextStyle(fontSize: 12, color: Colors.orange.shade800))),
        ]),
      );
    }
    if (sync.status == SyncStatus.error) {
      return Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          Icon(Icons.sync_problem, size: 14, color: Colors.red.shade700),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('Sync failed', style: TextStyle(fontSize: 12))),
          GestureDetector(
            onTap: onRetry,
            child: Text('Retry',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold)),
          ),
        ]),
      );
    }
    return const SizedBox.shrink();
  }
}

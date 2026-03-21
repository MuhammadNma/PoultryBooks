import 'package:flutter/material.dart';
import 'package:poultry_books/screens/settings_screen.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/profit_controller.dart';
import '../controllers/settings_controller.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profit_calculator_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../services/connectivity_sync_service.dart';

class BottomNavScreen extends StatefulWidget {
  final TransactionController txController;
  final ProfitController profitController;
  final SettingsController settingsController;
  final TransactionController transactionController;

  const BottomNavScreen({
    super.key,
    required this.txController,
    required this.profitController,
    required this.settingsController,
    required this.transactionController,
  });

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _index = 0;

  late final ConnectivitySyncService _syncService;

  @override
  void initState() {
    super.initState();
    _syncService = ConnectivitySyncService();
    _syncService.start(widget.profitController, widget.transactionController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            profitController: widget.profitController,
            transactionController: widget.transactionController,
            settingsController: widget.settingsController,
            goToTab: (i) => setState(() => _index = i),
          ),
          ProfitCalculatorScreen(
            profitController: widget.profitController,
            settingsController: widget.settingsController,
          ),
          CustomersScreen(txController: widget.txController),
          SettingsScreen(
            controller: widget.settingsController,
            profitController: widget.profitController,
            transactionController: widget.transactionController,
            // profitController: widget.profitController,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate), label: 'Calculator'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

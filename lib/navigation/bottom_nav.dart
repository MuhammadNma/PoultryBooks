import 'package:flutter/material.dart';
import 'package:poultry_profit_calculator/screens/settings_screen.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/profit_controller.dart';
import '../controllers/settings_controller.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profit_calculator_screen.dart';
import '../screens/customers/customers_screen.dart';

class BottomNavScreen extends StatefulWidget {
  final TransactionController txController;

  const BottomNavScreen({super.key, required this.txController});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _index = 0;

  final profitController = ProfitController();
  final settingsController = SettingsController();

  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await profitController.init();
    await settingsController.init();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            profitController: profitController,
            goToTab: (i) => setState(() => _index = i),
            settingsController: settingsController,
          ),
          ProfitCalculatorScreen(
            profitController: profitController,
            settingsController: settingsController,
          ),
          CustomersScreen(txController: widget.txController),
          SettingsScreen(controller: settingsController),
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

// import 'package:flutter/material.dart';
// import '../screens/customers/customers_screen.dart';
// import '../screens/profit_calculator_screen.dart';
// import '../screens/dashboard/dashboard_screen.dart';
// import '../controllers/transaction_controller.dart';
// import '../controllers/profit_controller.dart';
// import '../screens/calendar_profit_view.dart';

// class BottomNavScreen extends StatefulWidget {
//   final TransactionController txController;

//   const BottomNavScreen({super.key, required this.txController});

//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _index = 0;
//   final ProfitController _profitController = ProfitController();
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initProfitController();
//   }

//   Future<void> _initProfitController() async {
//     await _profitController.init();
//     setState(() => _isInitialized = true);
//   }

//   void _goToTab(int tabIndex) {
//     setState(() => _index = tabIndex);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final screens = [
//       DashboardScreen(
//         profitController: _profitController,
//         goToTab: (index) => _goToTab(index),
//       ),
//       const ProfitCalculatorScreen(),
//       CustomersScreen(txController: widget.txController),
//       CalendarProfitView(controller: _profitController), // index 3
//     ];

//     return Scaffold(
//       body: IndexedStack(
//         index: _index,
//         children: screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex:
//             _index > 2 ? 2 : _index, // keep bottom nav limited to 3 items
//         onTap: (i) => setState(() => _index = i),
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.dashboard), label: 'Dashboard'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.calculate), label: 'Calculator'),
//           BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/profit_controller.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profit_calculator_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/calendar_profit_view.dart';
import '../screens/settings_screen.dart';

class BottomNavScreen extends StatefulWidget {
  final TransactionController txController;

  const BottomNavScreen({super.key, required this.txController});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _index = 0;
  final ProfitController _profitController = ProfitController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initProfitController();
  }

  Future<void> _initProfitController() async {
    await _profitController.init();
    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  void _goToTab(int tabIndex) {
    setState(() => _index = tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      DashboardScreen(
        profitController: _profitController,
        goToTab: _goToTab,
      ),
      const ProfitCalculatorScreen(),
      CustomersScreen(txController: widget.txController),
      CalendarProfitView(controller: _profitController),
      const SettingsScreen(), // ✅ NEW
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

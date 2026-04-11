import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_books/controllers/profit_controller.dart';
import 'package:poultry_books/controllers/settings_controller.dart';
import 'package:poultry_books/main.dart';
import 'package:poultry_books/controllers/transaction_controller.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Use the same constructor as in main.dart
    final txController = TransactionController();
    final profitController = ProfitController();
    final settingsController = SettingsController();

    // Pump the widget using PoultryProfitApp
    await tester.pumpWidget(PoultryProfitApp(
      txController: txController,
      profitController: profitController,
      settingsController: settingsController,
    ));

    // Optional: verify the BottomNavScreen is loaded
    expect(find.text('Calculator'), findsOneWidget); // label of bottom nav
    expect(find.text('Customers'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_profit_calculator/main.dart';
import 'package:poultry_profit_calculator/controllers/transaction_controller.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Use the same constructor as in main.dart
    final txController = TransactionController();

    // Pump the widget using PoultryProfitApp
    await tester.pumpWidget(PoultryProfitApp(txController: txController));

    // Optional: verify the BottomNavScreen is loaded
    expect(find.text('Calculator'), findsOneWidget); // label of bottom nav
    expect(find.text('Customers'), findsOneWidget);
  });
}

// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poultry_books/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PoultryBooks App Integration Tests', () {
    // ---- AUTH ----
    group('Login Screen', () {
      testWidgets('login screen loads correctly', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show login screen if not logged in
        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
      });

      testWidgets('shows error on empty login', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Tap sign in without filling fields
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Enter a valid email'), findsOneWidget);
      });

      testWidgets('shows error on invalid email format', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Enter invalid email
        await tester.enterText(find.byType(TextFormField).first, 'notanemail');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Enter a valid email'), findsOneWidget);
      });

      testWidgets('navigate to signup screen', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        expect(find.text('Create Account'), findsWidgets);
        expect(find.byType(TextFormField), findsNWidgets(3));
      });

      testWidgets('navigate to forgot password screen', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.text('Send Reset Link'), findsOneWidget);
      });
    });

    // ---- ONBOARDING ----
    group('Onboarding', () {
      testWidgets('onboarding pages show correct content', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // If already logged in and not onboarded,
        // onboarding should show
        if (find.text('Welcome to PoultryBooks').evaluate().isNotEmpty) {
          expect(find.text('Welcome to PoultryBooks'), findsOneWidget);
          expect(find.text('Next'), findsOneWidget);

          // Tap Next to go to page 2
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          expect(find.text('Daily Egg Logging'), findsOneWidget);

          // Tap Next to go to page 3
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          expect(find.text('Record Sales as They Happen'), findsOneWidget);

          // Tap Next to go to page 4
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          expect(find.text('Log Expenses Anytime'), findsOneWidget);

          // Tap Next to go to setup page
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          expect(find.text('Set Up Your Farm'), findsOneWidget);
          expect(find.text('Get Started'), findsOneWidget);
        }
      });
    });

    // ---- DASHBOARD ----
    group('Dashboard', () {
      testWidgets('dashboard shows all KPI cards', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Only runs if already logged in and onboarded
        if (find.text('Eggs on Hand').evaluate().isNotEmpty) {
          expect(find.text('Eggs on Hand'), findsOneWidget);
          expect(find.text('Month Income'), findsOneWidget);
          expect(find.text('Month Expenses'), findsOneWidget);
          expect(find.text('Month Profit'), findsOneWidget);
        }
      });

      testWidgets('dashboard shows Quick Access section', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Quick Access').evaluate().isNotEmpty) {
          expect(find.text('Quick Access'), findsOneWidget);
          expect(find.text('Expenses'), findsOneWidget);
          expect(find.text('Reports'), findsOneWidget);
          expect(find.text('Flocks'), findsOneWidget);
        }
      });

      testWidgets('bottom nav has 5 tabs', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Dashboard').evaluate().isNotEmpty) {
          expect(find.text('Dashboard'), findsOneWidget);
          expect(find.text('Daily Log'), findsOneWidget);
          expect(find.text('Sales'), findsOneWidget);
          expect(find.text('Customers'), findsOneWidget);
          expect(find.text('Settings'), findsOneWidget);
        }
      });
    });

    // ---- NAVIGATION ----
    group('Bottom Navigation', () {
      testWidgets('can navigate to Daily Log tab', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Daily Log').evaluate().isNotEmpty) {
          await tester.tap(find.text('Daily Log'));
          await tester.pumpAndSettle();
          expect(find.text('Daily Egg Log'), findsOneWidget);
        }
      });

      testWidgets('can navigate to Sales tab', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Sales').evaluate().isNotEmpty) {
          await tester.tap(find.text('Sales'));
          await tester.pumpAndSettle();
          expect(find.text('Egg Sales'), findsOneWidget);
        }
      });

      testWidgets('can navigate to Customers tab', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Customers').evaluate().isNotEmpty) {
          await tester.tap(find.text('Customers'));
          await tester.pumpAndSettle();
          expect(find.text('Customers'), findsWidgets);
        }
      });

      testWidgets('can navigate to Settings tab', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Settings').evaluate().isNotEmpty) {
          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();
          expect(find.text('Farm Settings'), findsOneWidget);
          expect(find.text('Account'), findsOneWidget);
        }
      });
    });

    // ---- DAILY LOG ----
    group('Daily Log Screen', () {
      testWidgets('daily log shows date picker', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Daily Log').evaluate().isNotEmpty) {
          await tester.tap(find.text('Daily Log'));
          await tester.pumpAndSettle();

          expect(find.text('Change'), findsOneWidget);
        }
      });

      testWidgets('daily log shows no flocks message when empty',
          (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Daily Log').evaluate().isNotEmpty) {
          await tester.tap(find.text('Daily Log'));
          await tester.pumpAndSettle();

          // If no flocks added yet
          if (find.text('No active flocks').evaluate().isNotEmpty) {
            expect(find.text('No active flocks'), findsOneWidget);
          }
        }
      });
    });

    // ---- SALES ----
    group('Sales Screen', () {
      testWidgets('sales screen shows add button', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Sales').evaluate().isNotEmpty) {
          await tester.tap(find.text('Sales'));
          await tester.pumpAndSettle();

          expect(find.text('Record Sale'), findsOneWidget);
        }
      });

      testWidgets('record sale form opens correctly', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Sales').evaluate().isNotEmpty) {
          await tester.tap(find.text('Sales'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Record Sale'));
          await tester.pumpAndSettle();

          expect(find.text('Customer'), findsOneWidget);
          expect(find.text('Crates'), findsOneWidget);
          expect(find.text('Price per Crate (₦)'), findsOneWidget);
        }
      });
    });

    // ---- EXPENSES ----
    group('Expenses Screen', () {
      testWidgets('expenses screen opens from quick access', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Quick Access').evaluate().isNotEmpty) {
          // Scroll down to Quick Access
          await tester.scrollUntilVisible(
            find.text('Expenses'),
            200,
          );
          await tester.tap(find.text('Expenses').first);
          await tester.pumpAndSettle();

          expect(find.text('Add Expense'), findsOneWidget);
        }
      });

      testWidgets('add expense form shows all categories', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Quick Access').evaluate().isNotEmpty) {
          await tester.scrollUntilVisible(
            find.text('Add Expense'),
            200,
          );
          await tester.tap(find.text('Add Expense').first);
          await tester.pumpAndSettle();

          expect(find.text('Feed'), findsOneWidget);
          expect(find.text('Medication'), findsOneWidget);
          expect(find.text('Fuel'), findsOneWidget);
          expect(find.text('Salary'), findsOneWidget);
          expect(find.text('Crates'), findsOneWidget);
          expect(find.text('Repairs'), findsOneWidget);
          expect(find.text('Other'), findsOneWidget);
        }
      });
    });

    // ---- SETTINGS ----
    group('Settings Screen', () {
      testWidgets('settings shows farm name field', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Settings').evaluate().isNotEmpty) {
          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();

          expect(find.text('Farm Name'), findsOneWidget);
          expect(find.text('Default Price per Crate (₦)'), findsOneWidget);
          expect(find.text('Save Settings'), findsOneWidget);
        }
      });

      testWidgets('settings shows sign out button', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        if (find.text('Settings').evaluate().isNotEmpty) {
          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();

          expect(find.text('Sign Out'), findsOneWidget);
        }
      });
    });
  });
}

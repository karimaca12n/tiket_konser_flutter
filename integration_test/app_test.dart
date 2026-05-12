import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tiket_konser/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SoraiFest SQA End-to-End Test', () {
    testWidgets('Full User Flow: Splash -> Home -> Unauthorized Redirect -> Login', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // 1. Splash Screen Test
      // Check if SORAI FEST branding is visible
      expect(find.text('SORAI'), findsOneWidget);
      
      // Wait for splash duration (2.5s) plus some buffer
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 2. Home & Search Filtering Test
      // Verify we are on Home page
      expect(find.text('EXPLORE CONCERTS'), findsOneWidget);
      
      // Test search functionality
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Konser Tidak Ada');
      await tester.pumpAndSettle();
      
      // Expect "NO CONCERTS FOUND" based on project logic
      expect(find.text('NO CONCERTS FOUND'), findsOneWidget);

      // 3. Unauthorized Access Redirect Test
      // Try to click 'Orders' icon in bottom nav while not logged in
      // Icons.confirmation_number_outlined is used for Orders in MainScaffold
      await tester.tap(find.byIcon(Icons.confirmation_number_outlined));
      await tester.pumpAndSettle();

      // Expected: System redirects to Login Page because auth.isAuthenticated is false
      expect(find.text('WELCOME BACK'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);

      // 4. Login Automation
      // Enter credentials (Change with your test account if needed)
      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      
      // Tap Login Button
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();
      
      // Note: In real test, this will try to connect to localhost:8081
    });
  });
}

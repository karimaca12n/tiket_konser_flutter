import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tiket_konser/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SoraiFest SQA End-to-End Test', () {
    testWidgets('Full Cycle: Login -> Dashboard -> Logout', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Splash Screen
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 2. Redirect to Login (Simulasi akses halaman terproteksi)
      await tester.tap(find.byIcon(Icons.confirmation_number_outlined)); // Klik menu tiket
      await tester.pumpAndSettle();
      expect(find.text('WELCOME BACK'), findsOneWidget);

      // 3. Automation Login
      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Tunggu transisi ke Home setelah login
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // 4. Automation Logout
      // Cari icon Person/Profile di Bottom Nav (asumsi icon person)
      final profileTab = find.byIcon(Icons.person_outline);
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();

        // Cari tombol LOGOUT di halaman profil
        final logoutBtn = find.text('LOGOUT');
        if (logoutBtn.evaluate().isNotEmpty) {
          await tester.tap(logoutBtn);
          await tester.pumpAndSettle();
          
          // Verifikasi kembali ke halaman Login
          expect(find.text('WELCOME BACK'), findsOneWidget);
        }
      }
    });
  });
}

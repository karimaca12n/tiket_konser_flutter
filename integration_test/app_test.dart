import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tiket_konser/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SoraiFest SQA End-to-End Test', () {
    testWidgets('Full Cycle: Login -> Dashboard -> Logout', (tester) async {
      // 1. Jalankan Aplikasi
      app.main();
      await tester.pumpAndSettle();

      // 2. Splash Screen Delay (Menunggu animasi logo selesai)
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 3. Test Security Redirect (Triggered by clicking 'TIKET' tab)
      // Mencoba akses menu pesanan tanpa login
      await tester.tap(find.byIcon(Icons.confirmation_number_outlined)); 
      await tester.pumpAndSettle();
      
      // Verifikasi apakah diredirect ke halaman login (Terdapat teks 'WELCOME BACK')
      expect(find.text('WELCOME BACK'), findsOneWidget);

      // 4. Automation Login (Sesuai dengan controller di login_page.dart)
      // TextField indeks 0 = Email, indeks 1 = Password
      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      
      // Klik tombol 'LOGIN NOW' (Teks harus persis dengan LoginPage)
      await tester.tap(find.text('LOGIN NOW'));
      await tester.pumpAndSettle();

      // Menunggu proses API login dan transisi navigasi
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // 5. Automation Logout
      // Berpindah ke Tab Profile/Akun (Icons.person_outline di MainScaffold)
      final profileTab = find.byIcon(Icons.person_outline);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      // Menekan tombol LOGOUT di halaman profil
      final logoutBtn = find.text('LOGOUT');
      expect(logoutBtn, findsOneWidget); 
      
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();
      
      // Verifikasi Akhir: Berhasil logout dan kembali ke halaman Login
      expect(find.text('WELCOME BACK'), findsOneWidget);
    });
  });
}

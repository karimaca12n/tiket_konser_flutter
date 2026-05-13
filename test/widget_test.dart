import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/main.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';

void main() {
  testWidgets('SoraiFest Splash Screen Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap with MultiProvider because MyApp depends on it
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ConcertProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that our branding exists on the splash screen
    expect(find.text('SORAI'), findsOneWidget);
    expect(find.text('FEST'), findsOneWidget);

    // Verify loading indicator is present
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Handle the timer in SplashScreen
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:tiket_konser/pages/login_page.dart';
import 'package:tiket_konser/pages/register_page.dart';
import 'package:tiket_konser/pages/home_page.dart';
import 'package:tiket_konser/pages/concert_detail_page.dart';
import 'package:tiket_konser/pages/user_orders_page.dart';
import 'package:tiket_konser/pages/profile_page.dart';
import 'package:tiket_konser/admin/admin_dashboard.dart';
import 'package:tiket_konser/admin/admin_concerts.dart';
import 'package:tiket_konser/admin/admin_orders.dart';
import 'package:tiket_konser/admin/admin_users.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';
import 'package:tiket_konser/pages/payment_page.dart';
import 'package:tiket_konser/models/concert_model.dart';
import 'package:tiket_konser/widgets/main_scaffold.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConcertProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
    
    // User Shell with Bottom Nav
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(path: '/orders', builder: (context, state) => const UserOrdersPage()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
        GoRoute(
          path: '/concert/:id',
          builder: (context, state) => ConcertDetailPage(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/payment',
          builder: (context, state) => PaymentPage(concert: state.extra as ConcertModel),
        ),
      ],
    ),
    
    // Admin Routes
    GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboard()),
    GoRoute(path: '/admin/concerts', builder: (context, state) => const AdminConcertsPage()),
    GoRoute(path: '/admin/orders', builder: (context, state) => const AdminOrdersPage()),
    GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersPage()),
  ],
  redirect: (context, state) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
    
    if (!auth.isAuthenticated && !loggingIn && (state.matchedLocation.startsWith('/admin') || state.matchedLocation == '/orders' || state.matchedLocation == '/profile')) {
      return '/login';
    }
    
    if (auth.isAuthenticated && loggingIn) {
      return auth.isAdmin ? '/admin/dashboard' : '/home';
    }
    
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SoraiFest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
          bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
          titleLarge: GoogleFonts.pressStart2p(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          headlineMedium: GoogleFonts.pressStart2p(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
          ),
          hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border, width: 2),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.pressStart2p(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

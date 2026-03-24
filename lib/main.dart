import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiket_konser/pages/login_page.dart';
import 'package:tiket_konser/pages/register_page.dart';
import 'package:tiket_konser/pages/home_page.dart';
import 'package:tiket_konser/pages/concert_detail_page.dart';
import 'package:tiket_konser/pages/user_orders_page.dart';
import 'package:tiket_konser/admin/admin_dashboard.dart';
import 'package:tiket_konser/admin/admin_concerts.dart';
import 'package:tiket_konser/admin/admin_orders.dart';
import 'package:tiket_konser/admin/admin_users.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:tiket_konser/providers/concert_provider.dart';
import 'package:tiket_konser/providers/order_provider.dart';

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
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/concert/:id',
      builder: (context, state) => ConcertDetailPage(id: state.pathParameters['id']!),
    ),
    GoRoute(path: '/orders', builder: (context, state) => const UserOrdersPage()),
    
    // Admin Routes
    GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboard()),
    GoRoute(path: '/admin/concerts', builder: (context, state) => const AdminConcertsPage()),
    GoRoute(path: '/admin/orders', builder: (context, state) => const AdminOrdersPage()),
    GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersPage()),
  ],
  redirect: (context, state) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
    
    // Protected routes
    if (!auth.isAuthenticated && !loggingIn && (state.matchedLocation.startsWith('/admin') || state.matchedLocation == '/orders')) {
      return '/login';
    }
    
    // Prevent logged in users from seeing login page
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
      title: 'SoraiFest - Konser Tiket App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7),
          primary: const Color(0xFF673AB7),
          secondary: const Color(0xFF03DAC6),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

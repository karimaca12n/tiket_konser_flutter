import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:tiket_konser/providers/auth_provider.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final location = GoRouterState.of(context).matchedLocation;
    
    int getIndex() {
      if (location == '/home') return 0;
      if (location == '/orders') return 1;
      if (location == '/profile') return 2;
      return 0;
    }

    return Scaffold(
      body: child,
      // Tombol melayang hanya muncul untuk Admin agar bisa balik ke Panel Admin
      floatingActionButton: authProvider.isAdmin 
        ? FloatingActionButton.extended(
            onPressed: () => context.go('/admin/dashboard'),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            label: const Text("BACK TO ADMIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
          )
        : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.secondary.withOpacity(0.3), width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: getIndex(),
          onTap: (index) {
            if (index == 0) context.go('/home');
            if (index == 1) context.go('/orders');
            if (index == 2) context.go('/profile');
          },
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
            BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'TICKETS'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
          ],
        ),
      ),
    );
  }
}

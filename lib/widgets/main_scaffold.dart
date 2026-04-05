import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: const Color(0xFFE5E5E5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Tampilan WEB / TABLET
            return Center(
              child: Container(
                width: 450,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.border.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Scaffold(
                  body: child,
                  bottomNavigationBar: _buildBottomNav(context, getIndex()),
                  floatingActionButton: authProvider.isAdmin ? _buildAdminFAB(context) : null,
                ),
              ),
            );
          } else {
            // Tampilan MOBILE
            return Scaffold(
              body: child,
              bottomNavigationBar: _buildBottomNav(context, getIndex()),
              floatingActionButton: authProvider.isAdmin ? _buildAdminFAB(context) : null,
            );
          }
        },
      ),
    );
  }

  Widget _buildAdminFAB(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/admin/dashboard'),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.border,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        elevation: 0,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/orders');
          if (index == 2) context.go('/profile');
        },
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 8, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 8),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'TIKET',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'AKUN',
          ),
        ],
      ),
    );
  }
}

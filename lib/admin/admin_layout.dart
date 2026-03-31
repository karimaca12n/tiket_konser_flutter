import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String currentPath;
  final String title;

  const AdminLayout({
    super.key, 
    required this.child, 
    required this.currentPath,
    this.title = 'ADMIN PANEL',
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: AppColors.primary),
            onPressed: () => context.go('/home'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.secondary.withOpacity(0.2), height: 1),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.retroGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      'CORE SYSTEM',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: 'DASHBOARD',
              isActive: currentPath == '/admin/dashboard',
              onTap: () => context.go('/admin/dashboard'),
            ),
            _DrawerItem(
              icon: Icons.music_note_outlined,
              label: 'CONCERTS',
              isActive: currentPath == '/admin/concerts',
              onTap: () => context.go('/admin/concerts'),
            ),
            _DrawerItem(
              icon: Icons.shopping_bag_outlined,
              label: 'ORDERS',
              isActive: currentPath == '/admin/orders',
              onTap: () => context.go('/admin/orders'),
            ),
            _DrawerItem(
              icon: Icons.people_outline,
              label: 'USERS',
              isActive: currentPath == '/admin/users',
              onTap: () => context.go('/admin/users'),
            ),
            const Spacer(),
            const Divider(color: Colors.white10),
            _DrawerItem(
              icon: Icons.logout,
              label: 'LOGOUT',
              isActive: false,
              onTap: () => authProvider.logout().then((_) => context.go('/login')),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isActive ? AppColors.secondary : Colors.white54,
      ),
      title: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 13,
          color: isActive ? Colors.white : Colors.white54,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.secondary.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

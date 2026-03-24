import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AdminLayout({super.key, required this.child, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF1E1E2D),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'ADMIN PANEL',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 40),
                _SidebarItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: currentPath == '/admin/dashboard',
                  onTap: () => context.go('/admin/dashboard'),
                ),
                _SidebarItem(
                  icon: Icons.music_note,
                  label: 'Concerts',
                  isActive: currentPath == '/admin/concerts',
                  onTap: () => context.go('/admin/concerts'),
                ),
                _SidebarItem(
                  icon: Icons.shopping_cart,
                  label: 'Orders',
                  isActive: currentPath == '/admin/orders',
                  onTap: () => context.go('/admin/orders'),
                ),
                _SidebarItem(
                  icon: Icons.people,
                  label: 'Users',
                  isActive: currentPath == '/admin/users',
                  onTap: () => context.go('/admin/users'),
                ),
                const Divider(color: Colors.white24, height: 40, indent: 20, endIndent: 20),
                _SidebarItem(
                  icon: Icons.home,
                  label: 'View Home',
                  isActive: false,
                  onTap: () => context.go('/home'),
                ),
                const Spacer(),
                _SidebarItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  isActive: false,
                  onTap: () => authProvider.logout().then((_) => context.go('/login')),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getTitle(currentPath),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Text(authProvider.user?.name ?? 'Admin'),
                    ],
                  ),
                ),
                // Page Content
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F5F9),
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(String path) {
    if (path.contains('dashboard')) return 'Dashboard Overview';
    if (path.contains('concerts')) return 'Manage Concerts';
    if (path.contains('orders')) return 'Order Requests';
    if (path.contains('users')) return 'System Users';
    return 'Admin';
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
          border: Border(left: BorderSide(color: isActive ? Theme.of(context).primaryColor : Colors.transparent, width: 4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey[400]),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(color: isActive ? Colors.white : Colors.grey[400], fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

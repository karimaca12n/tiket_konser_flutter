import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: InkWell(
        onTap: () => context.go('/home'),
        child: Text(
          'SORAIFEST',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
      ),
      actions: [
        if (MediaQuery.of(context).size.width > 600) ...[
          TextButton(onPressed: () => context.go('/home'), child: const Text('Home')),
          if (authProvider.isAuthenticated)
            TextButton(onPressed: () => context.go('/orders'), child: const Text('My Orders')),
        ],
        const SizedBox(width: 20),
        if (authProvider.isAuthenticated) ...[
          if (authProvider.isAdmin)
            ElevatedButton(
              onPressed: () => context.go('/admin/dashboard'),
              child: const Text('Admin Panel'),
            ),
          const SizedBox(width: 10),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('Hello, ${user?.name}')),
              PopupMenuItem(
                onTap: () => authProvider.logout().then((_) => context.go('/login')),
                child: const Text('Logout'),
              ),
            ],
            child: const CircleAvatar(child: Icon(Icons.person)),
          ),
        ] else ...[
          OutlinedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => context.go('/register'),
            child: const Text('Register'),
          ),
        ],
        const SizedBox(width: 20),
      ],
    );
  }
}

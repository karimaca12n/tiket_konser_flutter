import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: AppColors.surface,
      title: InkWell(
        onTap: () => context.go('/home'),
        child: Text(
          'SORAIFEST',
          style: GoogleFonts.pressStart2p(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(color: AppColors.border, height: 2),
      ),
      actions: [
        if (MediaQuery.of(context).size.width > 600) ...[
          _NavButton(label: 'HOME', onTap: () => context.go('/home')),
          if (authProvider.isAuthenticated)
            _NavButton(label: 'ORDERS', onTap: () => context.go('/orders')),
        ],
        const SizedBox(width: 20),
        if (authProvider.isAuthenticated) ...[
          if (authProvider.isAdmin)
            GestureDetector(
              onTap: () => context.go('/admin/dashboard'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
                ),
                child: Text(
                  'ADMIN',
                  style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(width: 10),
          PopupMenuButton<void>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border, width: 2),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                enabled: false,
                child: Text(
                  'HELLO, ${user?.name.toUpperCase()}',
                  style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textPrimary),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                onTap: () {
                  final router = GoRouter.of(context);
                  authProvider.logout().then((_) => router.go('/login'));
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 16, color: AppColors.rejected),
                    const SizedBox(width: 10),
                    Text(
                      'LOGOUT',
                      style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.rejected),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.secondary,
                radius: 18,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: GoogleFonts.pressStart2p(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ] else ...[
          _NavButton(label: 'LOGIN', onTap: () => context.go('/login')),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.go('/register'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
              ),
              child: Text(
                'JOIN',
                style: GoogleFonts.pressStart2p(fontSize: 8, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        const SizedBox(width: 20),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.pressStart2p(
          fontSize: 10,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


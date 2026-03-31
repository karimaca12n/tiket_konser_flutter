import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiket_konser/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tiket_konser/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => context.go('/home'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Icon(Icons.rocket_launch, size: 80, color: AppColors.primary),
                const SizedBox(height: 20),
                Text(
                  'LOGIN',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                    letterSpacing: 4,
                    shadows: [
                      const Shadow(color: AppColors.secondary, blurRadius: 15),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Role Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _RoleButton(
                          label: 'USER',
                          isSelected: _selectedRole == 'user',
                          onTap: () => setState(() => _selectedRole = 'user'),
                        ),
                      ),
                      Expanded(
                        child: _RoleButton(
                          label: 'ADMIN',
                          isSelected: _selectedRole == 'admin',
                          onTap: () => setState(() => _selectedRole = 'admin'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'EMAIL',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'PASSWORD',
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : ElevatedButton(
                          onPressed: () async {
                            final success = await authProvider.login(
                              _emailController.text,
                              _passwordController.text,
                              _selectedRole,
                            );
                            if (success) {
                              if (_selectedRole == 'admin') {
                                context.go('/admin/dashboard');
                              } else {
                                context.go('/home');
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.rejected,
                                  content: Text('ACCESS DENIED: Check Credentials'),
                                ),
                              );
                            }
                          },
                          child: const Text('ENGAGE'),
                        ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text(
                    'CREATE NEW ACCOUNT',
                    style: TextStyle(
                      color: AppColors.secondary.withOpacity(0.8),
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.retroGradient : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white24,
            ),
          ),
        ),
      ),
    );
  }
}

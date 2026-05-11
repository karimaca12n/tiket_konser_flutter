import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:tiket_konser/core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Navigate to home after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  border: Border.all(color: AppColors.border, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      offset: Offset(8, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.confirmation_number,
                      size: 64,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SORAI',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'FEST',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            Text(
              'LOADING EXPERIENCE...',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.border.withValues(alpha: 0.1),
                color: AppColors.primary,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

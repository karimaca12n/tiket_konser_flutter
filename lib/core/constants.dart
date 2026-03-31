import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D0221); // Dark Space
  static const Color surface = Color(0xFF1B065E);    // Deep Purple
  static const Color primary = Color(0xFFBC00DD);    // Neon Pink
  static const Color secondary = Color(0xFF00F5FF);  // Neon Cyan
  static const Color accent = Color(0xFF70FF00);     // Neon Lime
  
  static const Color pending = Color(0xFFFFD700);    // Retro Gold
  static const Color approved = Color(0xFF00FF9F);   // Matrix Green
  static const Color rejected = Color(0xFFFF0055);   // Cyber Red

  static const LinearGradient retroGradient = LinearGradient(
    colors: [Color(0xFFBC00DD), Color(0xFF00F5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static BoxDecoration neonCard = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.secondary.withOpacity(0.5), width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

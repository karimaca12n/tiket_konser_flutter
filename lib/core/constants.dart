import 'package:flutter/material.dart';

class AppColors {
  // Retro Minimal + Comic Accent Palette
  static const Color background = Color(0xFFFDFDFD); // Off White
  static const Color surface = Color(0xFFFFFFFF);    // Pure White
  static const Color primary = Color(0xFFFF4D4D);    // Comic Red
  static const Color secondary = Color(0xFFFFD166);  // Comic Yellow
  static const Color accent = Color(0xFF06D6A0);     // Comic Green
  static const Color border = Color(0xFF1A1A1A);     // Strong Black Border
  
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  
  static const Color pending = Color(0xFFFFD166);
  static const Color approved = Color(0xFF06D6A0);
  static const Color rejected = Color(0xFFFF4D4D);

  static const LinearGradient retroGradient = LinearGradient(
    colors: [Color(0xFFFF4D4D), Color(0xFFFFD166)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static BoxDecoration retroCard = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border, width: 2),
    boxShadow: const [
      BoxShadow(
        color: AppColors.border,
        offset: Offset(4, 4),
      ),
    ],
  );

  static BoxDecoration comicContainer = BoxDecoration(
    color: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 2),
    boxShadow: const [
      BoxShadow(
        color: AppColors.border,
        offset: Offset(4, 4),
      ),
    ],
  );
}

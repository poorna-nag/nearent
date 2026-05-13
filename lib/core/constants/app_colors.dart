import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF00C853);
  static const Color primaryDark = Color(0xFF00952E);
  static const Color primaryLight = Color(0xFF5EFC82);
  static const Color primaryContainer = Color(0xFFE8F5E9);

  // Secondary
  static const Color secondary = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF5E92F3);
  static const Color secondaryContainer = Color(0xFFE3F2FD);

  // Accent
  static const Color accent = Color(0xFFFF6F00);
  static const Color accentLight = Color(0xFFFFCA28);

  // Neutrals
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0BEC5);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF0288D1);

  // Borders
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF3A3A3A);

  // Divider
  static const Color divider = Color(0xFFF0F0F0);
  static const Color dividerDark = Color(0xFF303030);

  // Shadows
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Listing type badges
  static const Color sellBadge = Color(0xFF00C853);
  static const Color rentBadge = Color(0xFF1565C0);
  static const Color exchangeBadge = Color(0xFFFF6F00);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

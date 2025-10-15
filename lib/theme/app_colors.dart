import 'package:flutter/material.dart';

/// SyncPad Color Palette
/// Based on the design system specification
class AppColors {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF7F7F7); // Off-white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white for cards
  static const Color lightTextPrimary = Color(0xFF2C3E50); // Charcoal
  static const Color lightTextSecondary = Color(0xFF7F8C8D); // Muted gray
  static const Color lightDivider = Color(0xFFE0E0E0); // Subtle separators

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1C1C1E); // Dark slate-gray
  static const Color darkSurface = Color(0xFF2C2C2E); // Slightly lighter for cards
  static const Color darkTextPrimary = Color(0xFFECF0F1); // Off-white
  static const Color darkTextSecondary = Color(0xFF95A5A6); // Muted gray
  static const Color darkDivider = Color(0xFF3A3A3C); // Subtle separators

  // Shared Colors (same for both themes)
  static const Color accent = Color(0xFF3498DB); // Deep blue for interactive elements
  static const Color error = Color(0xFFE74C3C); // For validation messages
  static const Color success = Color(0xFF27AE60); // For sync confirmations

  // Elevated surfaces for dark theme
  static const Color darkElevatedSurface = Color(0xFF3A3A3C);

  // Prevent instantiation
  AppColors._();
}

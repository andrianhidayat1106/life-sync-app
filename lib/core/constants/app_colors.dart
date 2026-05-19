import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary Brand Colors
  static const Color primary = Color(
    0xFF0F172A,
  ); // Slate-900 (Warna utama dari design system)
  static const Color secondary = Color(
    0xFF10B981,
  ); // Emerald-500 (Warna aksen sinkronisasi)

  // Neutral Colors (Background & Surfaces)
  static const Color background = Color(
    0xFFF8F9FF,
  ); // Surface (Biru pucat hampir putih)
  static const Color surfaceContainer = Color(0xFFEFF4FF); // Container-low

  // Typography Colors
  static const Color textPrimary = Color(
    0xFF0F172A,
  ); // On-surface (Slate gelap)
  static const Color textSecondary = Color(
    0xFF64748B,
  ); // Slate-500 (Warna teks varian)

  // Semantic Colors
  static const Color error = Color(
    0xFFB00020,
  ); // Warna standar error yang harmonis
  static const Color success = Color(
    0xFF10B981,
  ); // Menggunakan emerald untuk keberhasilan

  // Additional Accents from Design System
  static const Color outline = Color(0xFFCBDBF5); // Border & Outline-variant
}

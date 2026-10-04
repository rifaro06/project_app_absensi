import 'package:flutter/material.dart';

class AppColors {
  // Palet Warna Resmi PPKD (Diekstrak langsung dari Logo Resmi PPKD)
  static const Color primary = Color(
    0xFF237C99,
  ); // Deep Teal PPKD (Buku & Tipografi Logo)
  static const Color primaryLight = Color(
    0xFF8CD0EE,
  ); // Sky Blue Cerah (Roda Gigi Luar Logo)
  static const Color primaryDark = Color(
    0xFF18586E,
  ); // Deep Ocean Teal (Shading & Dark Contrast)

  // Warna Aksen Resmi dari Logo
  static const Color accentGreen = Color(
    0xFF2FB774,
  ); // Hijau Daun (Tunas Lampu) untuk Sukses/Check-In
  static const Color accentCoral = Color(
    0xFFEF5B66,
  ); // Merah Coral (Fitting Lampu) untuk Pulang/Batal
  static const Color accentWarning = Color(
    0xFFF59E0B,
  ); // Amber / Oranye untuk Izin/Perhatian

  // Background & Surface
  static const Color backgroundLight = Color(
    0xFFF8FAFC,
  ); // Latar terang bersih modern
  static const Color backgroundDark = Color(
    0xFF0E1A20,
  ); // Latar gelap elegan dengan undertone teal
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(
    0xFF16272F,
  ); // Card gelap harmonis dan nyaman di mata

  // Tipografi
  static const Color textLight = Color(0xFF1A2830); // Teks utama mode terang
  static const Color textDark = Color(0xFFF0F6F8); // Teks utama mode gelap
  static const Color textGrey = Color(0xFF728A96); // Teks sekunder / keterangan
}

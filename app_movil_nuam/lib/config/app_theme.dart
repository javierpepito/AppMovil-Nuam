import 'package:flutter/material.dart';

/// Tema visual de la aplicación NUAM
class AppTheme {
  // ========================================
  // COLORES PRINCIPALES
  // ========================================
  
  /// Naranja NUAM (color principal)
  static const Color primary = Color(0xFFFF6B35);
  
  /// Negro/Gris oscuro (secundario)
  static const Color secondary = Color(0xFF2C3E50);
  
  /// Verde (aprobado)
  static const Color success = Color(0xFF28A745);
  
  /// Rojo (rechazado)
  static const Color danger = Color(0xFFDC3545);
  
  /// Amarillo (pendiente)
  static const Color warning = Color(0xFFFFC107);
  
  /// Azul (información)
  static const Color info = Color(0xFF17A2B8);
  
  /// Gris claro (fondos)
  static const Color lightGray = Color(0xFFF5F5F5);
  
  /// Gris medio (bordes)
  static const Color mediumGray = Color(0xFFBDBDBD);
  
  /// Gris oscuro (textos secundarios)
  static const Color darkGray = Color(0xFF757575);
  
  // ========================================
  // TEMA CLARO
  // ========================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colores principales
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        error: danger,
        brightness: Brightness.light,
      ),
      
      // AppBar
      appBarTheme:  const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius. circular(8),
          ),
          elevation: 2,
        ),
      ),
      
      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
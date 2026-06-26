import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual do aplicativo (claro e escuro).
///
/// Usa Material 3 com uma paleta "gastronomica" quente (terracota + verde),
/// tipografia elegante (Playfair Display nos titulos + Inter no corpo) e
/// componentes arredondados e modernos.
class AppTheme {
  // Cores base da identidade visual.
  static const Color _coral = Color(0xFFE2583E); // primaria (terracota/coral)
  static const Color _verde = Color(0xFF2E8B57); // secundaria (ervas)
  static const Color _ambar = Color(0xFFF2A65A); // destaque (dourado)

  /// Tema claro.
  static ThemeData get claro => _construir(Brightness.light);

  /// Tema escuro.
  static ThemeData get escuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final bool ehEscuro = brilho == Brightness.dark;

    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: _coral,
      brightness: brilho,
    ).copyWith(
      primary: _coral,
      secondary: _verde,
      tertiary: _ambar,
    );

    final Color fundo =
        ehEscuro ? const Color(0xFF14110E) : const Color(0xFFFFF8F2);
    final Color superficie =
        ehEscuro ? const Color(0xFF211C18) : Colors.white;
    final Color textoForte =
        ehEscuro ? const Color(0xFFF3ECE4) : const Color(0xFF2C2320);

    final TextTheme baseTexto = GoogleFonts.interTextTheme(
      ThemeData(brightness: brilho).textTheme,
    );

    final TextTheme texto = baseTexto.copyWith(
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textoForte,
        height: 1.1,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textoForte,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textoForte,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: textoForte),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textoForte.withOpacity(0.85),
      ),
      labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      colorScheme: esquema,
      scaffoldBackgroundColor: fundo,
      textTheme: texto,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ehEscuro
            ? Colors.white.withOpacity(0.06)
            : _coral.withOpacity(0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: esquema.outline.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _coral, width: 1.8),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _coral,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _coral,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _coral,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: _coral.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: esquema.outline.withOpacity(0.12)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _coral.withOpacity(ehEscuro ? 0.18 : 0.10),
        side: BorderSide.none,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textoForte,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _coral,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: superficie,
        indicatorColor: _coral.withOpacity(0.16),
        elevation: 3,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  /// Gradiente principal usado em AppBars e destaques.
  static const LinearGradient gradientePrincipal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE2583E), Color(0xFFF2A65A)],
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration following Material Design 3 principles
/// with custom NEARBY PG brand colors and typography
class AppTheme {
  // Primary brand colors
  static const Color emeraldGreen = Color(0xFF2E7D32);
  static const Color lightMint = Color(0xFFA5D6A7);
  static const Color warmYellow = Color(0xFFFFEB3B);
  static const Color lightGray = Color(0xFFF9F9F9);
  static const Color deepCharcoal = Color(0xFF212121);
  static const Color secondaryGreen = Color(0xFF66BB6A);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Spacing constants
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius constants
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 50.0;

  // Elevation constants
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: emeraldGreen,
        secondary: secondaryGreen,
        tertiary: lightMint,
        surface: white,
        error: error,
        onPrimary: white,
        onSecondary: white,
        onTertiary: deepCharcoal,
        onSurface: deepCharcoal,
        onError: white,
        outline: gray300,
        outlineVariant: gray200,
      ),

      // Scaffold
      scaffoldBackgroundColor: lightGray,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: deepCharcoal,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: gray300.withOpacity(0.5),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: deepCharcoal,
        ),
        iconTheme: const IconThemeData(color: deepCharcoal, size: 24),
        actionsIconTheme: const IconThemeData(color: deepCharcoal, size: 24),
      ),

      // Text theme
      textTheme: _buildTextTheme(deepCharcoal),

      // Button themes
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),

      // Input decoration theme
      inputDecorationTheme: _buildInputDecorationTheme(),

      // Card theme
      cardTheme: _buildCardTheme(),

      // Bottom navigation theme
      bottomNavigationBarTheme: _buildBottomNavigationTheme(),

      // Chip theme
      chipTheme: _buildChipTheme(),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: gray200,
        thickness: 1,
        space: 1,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: gray600, size: 24),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: gray600,
        textColor: deepCharcoal,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: deepCharcoal,
        ),
        subtitleTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: gray600,
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: emeraldGreen,
        linearTrackColor: gray200,
        circularTrackColor: gray200,
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: emeraldGreen,
        inactiveTrackColor: gray200,
        thumbColor: emeraldGreen,
        overlayColor: emeraldGreen.withOpacity(0.2),
        valueIndicatorColor: emeraldGreen,
        valueIndicatorTextStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return emeraldGreen;
          }
          return gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return emeraldGreen.withOpacity(0.5);
          }
          return gray300;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return emeraldGreen;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(white),
        side: const BorderSide(color: gray400, width: 2),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return emeraldGreen;
          }
          return gray400;
        }),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: lightMint,
        secondary: emeraldGreen,
        tertiary: secondaryGreen,
        surface: gray800,
        error: error,
        onPrimary: deepCharcoal,
        onSecondary: white,
        onTertiary: white,
        onSurface: white,
        onError: white,
        outline: gray600,
        outlineVariant: gray700,
      ),

      scaffoldBackgroundColor: gray900,
      textTheme: _buildTextTheme(white),
      // ... other dark theme configurations
    );
  }

  /// Build text theme with Google Fonts
  static TextTheme _buildTextTheme(Color primaryColor) {
    return TextTheme(
      // Display styles (Poppins)
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),

      // Headline styles (Poppins)
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.4,
      ),

      // Title styles (Poppins)
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.4,
      ),

      // Label styles (Inter SemiBold)
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),

      // Body styles (Roboto)
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: primaryColor == white ? gray400 : gray600,
        height: 1.5,
      ),
    );
  }

  /// Build elevated button theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: emeraldGreen,
        foregroundColor: white,
        elevation: 2,
        shadowColor: emeraldGreen.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return gray300;
          }
          if (states.contains(WidgetState.pressed)) {
            return emeraldGreen.withOpacity(0.8);
          }
          return emeraldGreen;
        }),
      ),
    );
  }

  /// Build outlined button theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: emeraldGreen,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: emeraldGreen, width: 1.5),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Build text button theme
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: emeraldGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Build input decoration theme
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: gray300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: gray300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: emeraldGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: gray500,
      ),
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: gray600,
      ),
    );
  }

  /// Build card theme
  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      elevation: 2,
      shadowColor: gray300.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// Build bottom navigation theme
  static BottomNavigationBarThemeData _buildBottomNavigationTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: emeraldGreen,
      unselectedItemColor: gray500,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  /// Build chip theme
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: gray100,
      selectedColor: lightMint,
      secondarySelectedColor: lightMint,
      disabledColor: gray200,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: deepCharcoal,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: emeraldGreen,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

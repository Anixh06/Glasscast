import 'package:flutter/material.dart';

class GlassColors {
  // Background gradients
  static const List<Color> dayGradient = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
    Color(0xFFf093fb),
  ];
  
  static const List<Color> nightGradient = [
    Color(0xFF0f0c29),
    Color(0xFF302b63),
    Color(0xFF24243e),
  ];
  
  static const List<Color> sunsetGradient = [
    Color(0xFFfa709a),
    Color(0xFFfee140),
  ];
  
  // Glass effect colors
  static const Color glassLight = Color(0xFFFFFFFF);
  static const Color glassMedium = Color(0xFFFFFFFF);
  static const Color glassHeavy = Color(0xFFFFFFFF);
  
  // Glass opacity levels
  static const double glassLightOpacity = 0.1;
  static const double glassMediumOpacity = 0.2;
  static const double glassHeavyOpacity = 0.3;
  
  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  
  // Accent colors
  static const Color accent = Color(0xFF667eea);
  static const Color accentLight = Color(0xFFf093fb);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  
  // Weather condition colors
  static const Color sunny = Color(0xFFFFB74D);
  static const Color cloudy = Color(0xFF90A4AE);
  static const Color rainy = Color(0xFF64B5F6);
  static const Color snowy = Color(0xFFE0F7FA);
  static const Color stormy = Color(0xFF5C6BC0);
}

class GlassTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GlassColors.accent,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      cardColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: Colors.transparent),
    );
  }
  
  // Glass container styles
  static BoxDecoration glassLightDecoration({
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return BoxDecoration(
      shape: shape,
      borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
      color: GlassColors.glassLight.withValues(alpha: GlassColors.glassLightOpacity),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }
  
  static BoxDecoration glassMediumDecoration({
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return BoxDecoration(
      shape: shape,
      borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
      color: GlassColors.glassMedium.withValues(alpha: GlassColors.glassMediumOpacity),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 30,
          spreadRadius: -5,
        ),
      ],
    );
  }
  
  static BoxDecoration glassHeavyDecoration({
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return BoxDecoration(
      shape: shape,
      borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
      color: GlassColors.glassHeavy.withValues(alpha: GlassColors.glassHeavyOpacity),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.4),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 40,
          spreadRadius: -5,
        ),
      ],
    );
  }
  
  // Gradient background helpers
  static BoxDecoration dayBackground({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: GlassColors.dayGradient,
      ),
      borderRadius: borderRadius,
    );
  }
  
  static BoxDecoration nightBackground({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: GlassColors.nightGradient,
      ),
      borderRadius: borderRadius,
    );
  }
  
  static BoxDecoration sunsetBackground({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: GlassColors.sunsetGradient,
      ),
      borderRadius: borderRadius,
    );
  }
}


import 'package:flutter/material.dart';

/// SimStruct App Colors - Unique Professional Engineering Color Palette
/// Inspired by structural blueprints, steel construction, and precision instruments
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // PRIMARY COLORS - Graphite Carbon (Strength & Reliability)
  // ═══════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF2D3142);  // Carbon Graphite
  static const Color primaryLight = Color(0xFF4F5565);
  static const Color primaryDark = Color(0xFF1A1D29);
  static const Color primarySoft = Color(0xFFE8E9ED);
  static const Color primaryMuted = Color(0xFFBFC2CC);

  // ═══════════════════════════════════════════════════════════════
  // SECONDARY COLORS - Copper Patina (Engineering Heritage)
  // ═══════════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFFBF8B67);  // Copper Bronze
  static const Color secondaryLight = Color(0xFFD4A574);
  static const Color secondaryDark = Color(0xFF9A6D4A);
  static const Color secondarySoft = Color(0xFFFDF6F0);

  // ═══════════════════════════════════════════════════════════════
  // ACCENT COLORS - Blueprint Cyan & Technical Highlights
  // ═══════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFF3A7CA5);  // Blueprint Blue
  static const Color accentLight = Color(0xFF5B9DC9);
  static const Color accentDark = Color(0xFF2B5F7E);
  
  static const Color cyan = Color(0xFF4ECDC4);  // Technical Teal
  static const Color cyanLight = Color(0xFF7EDDD6);
  static const Color cyanDark = Color(0xFF3AADA5);

  // Technical Orange (Safety/Warning Accent)
  static const Color purple = Color(0xFFD65A31);  // Safety Orange
  static const Color purpleLight = Color(0xFFE57B52);
  static const Color purpleDark = Color(0xFFB84520);
  static const Color purpleSoft = Color(0xFFFFF0EB);

  // ═══════════════════════════════════════════════════════════════
  // STATUS COLORS - Clear & Technical
  // ═══════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF2E8B57);  // Sea Green
  static const Color successLight = Color(0xFF50C878);
  static const Color successDark = Color(0xFF246B45);
  static const Color successSoft = Color(0xFFE8F5EE);

  static const Color warning = Color(0xFFE09F3E);  // Goldenrod
  static const Color warningLight = Color(0xFFF5C16C);
  static const Color warningDark = Color(0xFFBD8429);
  static const Color warningSoft = Color(0xFFFFF8EB);

  static const Color error = Color(0xFFBE3144);  // Deep Crimson
  static const Color errorLight = Color(0xFFD45867);
  static const Color errorDark = Color(0xFF9A2535);
  static const Color errorSoft = Color(0xFFFBE9EC);

  static const Color info = Color(0xFF3A7CA5);  // Blueprint Blue
  static const Color infoLight = Color(0xFF5B9DC9);
  static const Color infoDark = Color(0xFF2B5F7E);
  static const Color infoSoft = Color(0xFFE8F2F7);

  // ═══════════════════════════════════════════════════════════════
  // DARK THEME COLORS - Industrial Night Mode
  // ═══════════════════════════════════════════════════════════════
  static const Color darkBackground = Color(0xFF0D0F14);  // Deep Charcoal
  static const Color darkSurface = Color(0xFF14171F);
  static const Color darkSurfaceLight = Color(0xFF1E222D);
  static const Color darkSurfaceLighter = Color(0xFF2A303D);
  static const Color darkCard = Color(0xFF181C25);
  static const Color darkCardHover = Color(0xFF22272F);
  static const Color darkBorder = Color(0xFF2A303D);
  static const Color darkDivider = Color(0xFF1E222D);

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME COLORS - Blueprint White
  // ═══════════════════════════════════════════════════════════════
  static const Color lightBackground = Color(0xFFF5F7FA);  // Paper White
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFEEF1F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardHover = Color(0xFFF5F7FA);
  static const Color lightBorder = Color(0xFFDDE1E9);
  static const Color lightDivider = Color(0xFFEEF1F5);

  // ═══════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════
  // Dark Theme Text
  static const Color darkTextPrimary = Color(0xFFF0F2F5);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkTextDisabled = Color(0xFF4B5563);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  // Light Theme Text
  static const Color lightTextPrimary = Color(0xFF1A1D29);  // Carbon
  static const Color lightTextSecondary = Color(0xFF4F5565);
  static const Color lightTextMuted = Color(0xFF6B7280);
  static const Color lightTextDisabled = Color(0xFFBFC2CC);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // ═══════════════════════════════════════════════════════════════
  // THEME-AWARE ALIASES (for easy access in widgets)
  // ═══════════════════════════════════════════════════════════════
  // Background
  static const Color backgroundDark = darkBackground;
  static const Color backgroundLight = lightBackground;
  
  // Surface
  static const Color surfaceDark = darkSurface;
  static const Color surfaceLight = lightSurface;
  
  // Card
  static const Color cardDark = darkCard;
  static const Color cardLight = lightCard;
  
  // Border
  static const Color borderDark = darkBorder;
  static const Color borderLight = lightBorder;
  
  // Divider
  static const Color dividerDark = darkDivider;
  static const Color dividerLight = lightDivider;
  
  // Text Primary
  static const Color textPrimaryDark = darkTextPrimary;
  static const Color textPrimaryLight = lightTextPrimary;
  
  // Text Secondary
  static const Color textSecondaryDark = darkTextSecondary;
  static const Color textSecondaryLight = lightTextSecondary;
  
  // Text Tertiary
  static const Color textTertiaryDark = darkTextTertiary;
  static const Color textTertiaryLight = lightTextTertiary;
  
  // Shadow
  static const Color shadowLight = Color(0x0A000000);

  // ═══════════════════════════════════════════════════════════════
  // MATERIAL COLORS - Structure Simulation (Real Engineering)
  // ═══════════════════════════════════════════════════════════════
  static const Color steel = Color(0xFF71797E);  // Steel Gray
  static const Color concrete = Color(0xFF8E8E8E);  // Concrete
  static const Color aluminum = Color(0xFFA8A9AD);  // Aluminum
  static const Color wood = Color(0xFF8B4513);  // Saddle Brown

  // ═══════════════════════════════════════════════════════════════
  // AVATAR COLORS - Professional Engineering Palette
  // ═══════════════════════════════════════════════════════════════
  static const List<Color> avatarColors = [
    Color(0xFF2D3142),  // Carbon
    Color(0xFFBF8B67),  // Copper
    Color(0xFF3A7CA5),  // Blueprint
    Color(0xFF2E8B57),  // Sea Green
    Color(0xFFD65A31),  // Safety Orange
    Color(0xFF4ECDC4),  // Teal
    Color(0xFF9A6D4A),  // Bronze
    Color(0xFF4F5565),  // Slate
  ];
  
  static Color getAvatarColor(String name) {
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % avatarColors.length;
    return avatarColors[index];
  }

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS - Sophisticated & Industrial
  // ═══════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F5565), Color(0xFF2D3142)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A574), Color(0xFFBF8B67)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B9DC9), Color(0xFF3A7CA5)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D3142), Color(0xFF3A7CA5), Color(0xFFBF8B67)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8E9ED), Color(0xFFBFC2CC)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A574), Color(0xFF9A6D4A)],
  );

  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4ECDC4), Color(0xFF3A7CA5)],
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x80000000)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF181C25), Color(0xFF0D0F14)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x20FFFFFF), Color(0x08FFFFFF)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF50C878), Color(0xFF2E8B57)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5C16C), Color(0xFFE09F3E)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD45867), Color(0xFFBE3144)],
  );

  // Premium/Pro gradient
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBF8B67), Color(0xFF9A6D4A), Color(0xFF2D3142)],
    stops: [0.0, 0.5, 1.0],
  );

  // ═══════════════════════════════════════════════════════════════
  // BOX SHADOWS - Professional & Refined
  // ═══════════════════════════════════════════════════════════════
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 6),
      spreadRadius: -6,
    ),
  ];

  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.20),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> accentShadow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.20),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: secondary.withValues(alpha: 0.25),
      blurRadius: 32,
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> copperGlowShadow = [
    BoxShadow(
      color: secondary.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
}

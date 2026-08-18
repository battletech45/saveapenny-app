import 'package:flutter/material.dart';

abstract final class BrandPalette {
  static const Color lightPrimary = Color(0xFF3B5BC0);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFDDE3FB);
  static const Color lightOnPrimaryContainer = Color(0xFF0C1A52);

  static const Color darkPrimary = Color(0xFF9FB1F5);
  static const Color darkOnPrimary = Color(0xFF11205C);
  static const Color darkPrimaryContainer = Color(0xFF26346F);
  static const Color darkOnPrimaryContainer = Color(0xFFDDE3FB);
}

abstract final class NeutralPalette {
  static const Color lightBackground = Color(0xFFFBFBFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF1F3F5);
  static const Color lightBorder = Color(0xFFE4E7EB);
  static const Color lightTextPrimary = Color(0xFF1A1D21);
  static const Color lightTextSecondary = Color(0xFF5B6470);
  static const Color lightTextTertiary = Color(0xFF8A929E);

  static const Color darkBackground = Color(0xFF0E1013);
  static const Color darkSurface = Color(0xFF16191D);
  static const Color darkSurfaceSubtle = Color(0xFF1E2228);
  static const Color darkBorder = Color(0xFF2A2F36);
  static const Color darkTextPrimary = Color(0xFFF2F4F6);
  static const Color darkTextSecondary = Color(0xFFA8B0BA);
  static const Color darkTextTertiary = Color(0xFF6E7782);
}

abstract final class FinancePalette {
  static const Color lightIncome = Color(0xFF1F8A5B);
  static const Color lightIncomeSurface = Color(0xFFE5F4EC);
  static const Color lightExpense = Color(0xFFC04A3F);
  static const Color lightExpenseSurface = Color(0xFFFAE8E5);
  static const Color lightWarning = Color(0xFFB07A12);
  static const Color lightWarningSurface = Color(0xFFFBF1D8);
  static const Color lightInfo = Color(0xFF2E73A8);

  static const Color darkIncome = Color(0xFF4FC78E);
  static const Color darkIncomeSurface = Color(0xFF142A20);
  static const Color darkExpense = Color(0xFFEC8278);
  static const Color darkExpenseSurface = Color(0xFF33211F);
  static const Color darkWarning = Color(0xFFE0B65C);
  static const Color darkWarningSurface = Color(0xFF302813);
  static const Color darkInfo = Color(0xFF7FB6DD);
}

/// Categorical color sequence for charts that break amounts down by category
/// (spending by category, category-based bars). Distinct from
/// [FinancePalette], which is reserved for income/expense/warning semantics.
abstract final class ChartPalette {
  static const List<Color> light = <Color>[
    Color(0xFF3B5BC0),
    Color(0xFF2E9E8F),
    Color(0xFFB07A12),
    Color(0xFF8A5FD1),
    Color(0xFFC0574A),
    Color(0xFF3E8ECF),
    Color(0xFF6E8B3D),
    Color(0xFFC0568E),
  ];

  static const List<Color> dark = <Color>[
    Color(0xFF9FB1F5),
    Color(0xFF6FD3C4),
    Color(0xFFE0B65C),
    Color(0xFFBBA1EA),
    Color(0xFFEC8278),
    Color(0xFF7FB6DD),
    Color(0xFFA3C97B),
    Color(0xFFE297C0),
  ];

  static Color forIndex(List<Color> palette, int index) =>
      palette[index % palette.length];
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// Concrete shadow treatments for the design system's 3 elevation levels.
/// Level 0 (hairline-only cards) intentionally has no shadow.
abstract final class AppElevation {
  static const List<BoxShadow> level1 = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 8), blurRadius: 24),
  ];
}

abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
}

abstract final class AppFontWeight {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
}

const List<FontFeature> kTabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

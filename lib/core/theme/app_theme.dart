import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/tokens.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSubtle,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSubtle:
          Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ?? surfaceSubtle,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textTertiary:
          Color.lerp(textTertiary, other.textTertiary, t) ?? textTertiary,
    );
  }
}

@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  const FinanceColors({
    required this.income,
    required this.incomeSurface,
    required this.expense,
    required this.expenseSurface,
    required this.warning,
    required this.warningSurface,
    required this.info,
  });

  final Color income;
  final Color incomeSurface;
  final Color expense;
  final Color expenseSurface;
  final Color warning;
  final Color warningSurface;
  final Color info;

  Color forAmount(num amount) {
    if (amount > 0) {
      return income;
    }
    if (amount < 0) {
      return expense;
    }
    return info;
  }

  @override
  FinanceColors copyWith({
    Color? income,
    Color? incomeSurface,
    Color? expense,
    Color? expenseSurface,
    Color? warning,
    Color? warningSurface,
    Color? info,
  }) {
    return FinanceColors(
      income: income ?? this.income,
      incomeSurface: incomeSurface ?? this.incomeSurface,
      expense: expense ?? this.expense,
      expenseSurface: expenseSurface ?? this.expenseSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      info: info ?? this.info,
    );
  }

  @override
  FinanceColors lerp(ThemeExtension<FinanceColors>? other, double t) {
    if (other is! FinanceColors) {
      return this;
    }

    return FinanceColors(
      income: Color.lerp(income, other.income, t) ?? income,
      incomeSurface:
          Color.lerp(incomeSurface, other.incomeSurface, t) ?? incomeSurface,
      expense: Color.lerp(expense, other.expense, t) ?? expense,
      expenseSurface:
          Color.lerp(expenseSurface, other.expenseSurface, t) ?? expenseSurface,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningSurface:
          Color.lerp(warningSurface, other.warningSurface, t) ?? warningSurface,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}

abstract final class AppTheme {
  static ThemeData light() => _buildTheme(
    brightness: Brightness.light,
    colors: const AppColors(
      background: NeutralPalette.lightBackground,
      surface: NeutralPalette.lightSurface,
      surfaceSubtle: NeutralPalette.lightSurfaceSubtle,
      border: NeutralPalette.lightBorder,
      textPrimary: NeutralPalette.lightTextPrimary,
      textSecondary: NeutralPalette.lightTextSecondary,
      textTertiary: NeutralPalette.lightTextTertiary,
    ),
    finance: const FinanceColors(
      income: FinancePalette.lightIncome,
      incomeSurface: FinancePalette.lightIncomeSurface,
      expense: FinancePalette.lightExpense,
      expenseSurface: FinancePalette.lightExpenseSurface,
      warning: FinancePalette.lightWarning,
      warningSurface: FinancePalette.lightWarningSurface,
      info: FinancePalette.lightInfo,
    ),
    primary: BrandPalette.lightPrimary,
    onPrimary: BrandPalette.lightOnPrimary,
    primaryContainer: BrandPalette.lightPrimaryContainer,
    onPrimaryContainer: BrandPalette.lightOnPrimaryContainer,
  );

  static ThemeData dark() => _buildTheme(
    brightness: Brightness.dark,
    colors: const AppColors(
      background: NeutralPalette.darkBackground,
      surface: NeutralPalette.darkSurface,
      surfaceSubtle: NeutralPalette.darkSurfaceSubtle,
      border: NeutralPalette.darkBorder,
      textPrimary: NeutralPalette.darkTextPrimary,
      textSecondary: NeutralPalette.darkTextSecondary,
      textTertiary: NeutralPalette.darkTextTertiary,
    ),
    finance: const FinanceColors(
      income: FinancePalette.darkIncome,
      incomeSurface: FinancePalette.darkIncomeSurface,
      expense: FinancePalette.darkExpense,
      expenseSurface: FinancePalette.darkExpenseSurface,
      warning: FinancePalette.darkWarning,
      warningSurface: FinancePalette.darkWarningSurface,
      info: FinancePalette.darkInfo,
    ),
    primary: BrandPalette.darkPrimary,
    onPrimary: BrandPalette.darkOnPrimary,
    primaryContainer: BrandPalette.darkPrimaryContainer,
    onPrimaryContainer: BrandPalette.darkOnPrimaryContainer,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColors colors,
    required FinanceColors finance,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          surface: colors.surface,
          onSurface: colors.textPrimary,
          error: finance.expense,
          onError: onPrimary,
          outline: colors.border,
        );

    final baseTextTheme =
        Typography.material2021(
          platform: TargetPlatform.iOS,
          colorScheme: colorScheme,
        ).black.apply(
          bodyColor: colors.textPrimary,
          displayColor: colors.textPrimary,
        );

    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 34,
        height: 40 / 34,
        fontWeight: AppFontWeight.semibold,
        fontFeatures: kTabularFigures,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: AppFontWeight.semibold,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: AppFontWeight.semibold,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: AppFontWeight.regular,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: AppFontWeight.regular,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: AppFontWeight.medium,
      ),
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: BorderSide(color: colors.border),
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      canvasColor: colors.background,
      dividerColor: colors.border,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors, finance],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.title,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: finance.expense),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: finance.expense, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(AppSpacing.giant),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: textTheme.title,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onPrimaryContainer,
          minimumSize: const Size.fromHeight(AppSpacing.giant),
          side: BorderSide.none,
          textStyle: textTheme.title,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(AppSpacing.giant),
          textStyle: textTheme.title,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSubtle,
        selectedColor: primaryContainer,
        labelStyle: textTheme.label,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

extension BuildContextThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  FinanceColors get finance => Theme.of(this).extension<FinanceColors>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension AppTextThemeX on TextTheme {
  TextStyle get displayMoney => headlineLarge!.copyWith(
    fontFeatures: kTabularFigures,
    fontWeight: AppFontWeight.semibold,
  );

  TextStyle get headline => headlineSmall!;

  TextStyle get title => titleMedium!;

  TextStyle get body => bodyMedium!;

  TextStyle get label => labelMedium!;

  TextStyle get money => bodyMedium!.copyWith(
    fontFeatures: kTabularFigures,
    fontWeight: AppFontWeight.semibold,
  );
}

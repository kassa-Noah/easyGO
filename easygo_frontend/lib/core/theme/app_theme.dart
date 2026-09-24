import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const double _defaultRadius = 16;

  static ThemeData get lightTheme {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      scaffoldBackgroundColor:
          const Color(0xFFF4F7FB),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor:
            Colors.transparent,
        foregroundColor:
            AppColors.textPrimary,
        surfaceTintColor:
            Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: Colors.white
            .withValues(alpha: 0.80),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            _defaultRadius,
          ),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            _defaultRadius,
          ),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            _defaultRadius,
          ),
          borderSide:
              const BorderSide(
            color: AppColors.primary,
            width: 1.7,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              _defaultRadius,
            ),
          ),
          textStyle:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.primary,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 16,
          ),
          side: const BorderSide(
            color: AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              _defaultRadius,
            ),
          ),
        ),
      ),

      navigationBarTheme:
          NavigationBarThemeData(
        elevation: 0,
        backgroundColor:
            Colors.white.withValues(
          alpha: 0.92,
        ),
        indicatorColor:
            AppColors.primaryLight
                .withValues(
          alpha: 0.18,
        ),
        labelTextStyle:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.primary,
              );
            }

            return const TextStyle(
              fontSize: 12,
              color: AppColors
                  .textSecondary,
            );
          },
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white
            .withValues(alpha: 0.82),
        surfaceTintColor:
            Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          side: BorderSide(
            color: Colors.white
                .withValues(
              alpha: 0.75,
            ),
          ),
        ),
      ),

      dividerTheme:
          const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color darkBackground =
        Color(0xFF09111F);

    const Color darkSurface =
        Color(0xFF111C2E);

    const Color darkSurfaceLight =
        Color(0xFF18263A);

    const Color darkTextPrimary =
        Color(0xFFF3F6FA);

    const Color darkTextSecondary =
        Color(0xFFABB7C8);

    const Color darkBorder =
        Color(0xFF29384D);

    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      secondary:
          AppColors.secondaryLight,
      surface: darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      scaffoldBackgroundColor:
          darkBackground,

      appBarTheme:
          const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor:
            Colors.transparent,
        foregroundColor:
            darkTextPrimary,
        surfaceTintColor:
            Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
      ),

      textTheme:
          const TextTheme(
        headlineLarge: TextStyle(
          color: darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          color: darkTextSecondary,
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceLight
            .withValues(alpha: 0.78),
        labelStyle:
            const TextStyle(
          color: darkTextSecondary,
        ),
        hintStyle:
            const TextStyle(
          color: darkTextSecondary,
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            _defaultRadius,
          ),
          borderSide:
              const BorderSide(
            color: darkBorder,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            _defaultRadius,
          ),
          borderSide:
              const BorderSide(
            color: darkBorder,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            _defaultRadius,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.primaryLight,
            width: 1.7,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              _defaultRadius,
            ),
          ),
          textStyle:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.primaryLight,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 16,
          ),
          side: const BorderSide(
            color:
                AppColors.primaryLight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              _defaultRadius,
            ),
          ),
        ),
      ),

      navigationBarTheme:
          NavigationBarThemeData(
        elevation: 0,
        backgroundColor:
            darkSurface.withValues(
          alpha: 0.94,
        ),
        indicatorColor:
            AppColors.primary
                .withValues(
          alpha: 0.30,
        ),
        labelTextStyle:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color: AppColors
                    .primaryLight,
              );
            }

            return const TextStyle(
              fontSize: 12,
              color:
                  darkTextSecondary,
            );
          },
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface
            .withValues(alpha: 0.78),
        surfaceTintColor:
            Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          side: BorderSide(
            color: Colors.white
                .withValues(
              alpha: 0.08,
            ),
          ),
        ),
      ),

      dividerTheme:
          const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
    );
  }
}
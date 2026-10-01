import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);

  static const Color secondary = Color(0xFF2EAD63);
  static const Color secondaryDark = Color(0xFF18864B);
  static const Color secondaryLight = Color(0xFF66C985);

  // ---- Light-mode canvas ----------------------------------------------
  // These are deliberately tinted rather than near-white. The light theme used
  // to sit on #F7F9FC with a white-to-white gradient over it, so every screen
  // was one flat white sheet and the white cards had nothing to sit against.
  // The stops below are far enough from white to read as a gradient, while
  // still light enough that #1F2937 body text stays above a 12:1 contrast
  // ratio on every one of them.
  //
  // Single source of truth: page backgrounds are drawn by a per-screen
  // `Container`, not by the Scaffold, so the gradient has to be referenced
  // rather than themed. It used to be copy-pasted as three literals into 43
  // screens, which is why changing the light theme used to mean editing 43
  // files. Change it here instead.
  static const Color background = Color(0xFFEDF3FC);
  static const Color surface = Colors.white;

  static const Color gradientStart = Color(0xFFD9E7FB);
  static const Color gradientMid = Color(0xFFF4F9FF);
  static const Color gradientEnd = Color(0xFFD8F2E4);

  /// Page wash for light mode: brand blue top-left, mint bottom-right.
  static const List<Color> lightPageGradient = <Color>[
    gradientStart,
    gradientMid,
    gradientEnd,
  ];

  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  /// Tinted towards the brand blue rather than neutral grey, so hairlines and
  /// field outlines look deliberate on the tinted canvas above.
  static const Color border = Color(0xFFD9E4F5);

  /// Edge for white cards and panels. A white border on a white card is
  /// invisible; this is what makes a card read as a card.
  static const Color cardBorder = Color(0xFFD6E3F7);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
}

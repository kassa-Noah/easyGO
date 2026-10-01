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

  /// Page wash for the customer console: brand blue top-left, mint
  /// bottom-right. The agency and admin washes live with the console
  /// identities further down.
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

  // ---- Console identities ---------------------------------------------
  //
  // One account is only ever in one of the three consoles, so the app can
  // carry that console's identity for as long as the session lasts. The rule
  // for where an accent may be used is narrow on purpose:
  //
  //   accent  = where you are  (nav bar, canvas, dashboard hero)
  //   primary = what you can do (buttons, links, focused fields)
  //
  // Keeping actions blue in all three consoles is deliberate. A green
  // "Confirm booking" in the agency app next to a blue one in the customer app
  // would suggest the two do different things; they do not.
  //
  // [adminAccent] is a new colour rather than [warning]. That amber already
  // means "this needs your attention" on a status chip, and one colour cannot
  // carry two meanings.
  static const Color agencyCanvas = Color(0xFFEAF6EF);
  static const Color adminCanvas = Color(0xFFFDF1E7);

  static const Color clientAccent = primary;
  static const Color clientAccentDark = primaryDark;
  static const Color clientAccentLight = primaryLight;

  static const Color agencyAccent = secondary;
  static const Color agencyAccentDark = secondaryDark;
  static const Color agencyAccentLight = secondaryLight;

  /// The control desk. Orange, because it is the one console that acts on the
  /// whole platform rather than on its own work.
  static const Color adminAccent = Color(0xFFEA6A16);
  static const Color adminAccentDark = Color(0xFFB4440C);
  static const Color adminAccentLight = Color(0xFFF5A15E);

  /// Page wash for the agency console: mint into pale teal.
  ///
  /// The admin console has no wash of its own. Every admin screen opens with an
  /// AppBar, and a gradient that begins below an AppBar leaves a visible seam,
  /// so [adminCanvas] carries that console instead.
  static const List<Color> agencyPageGradient = <Color>[
    Color(0xFFD2F0DF),
    Color(0xFFF5FCF8),
    Color(0xFFCFE9F6),
  ];

  static const ConsoleAccent client = ConsoleAccent(
    base: clientAccent,
    dark: clientAccentDark,
    light: clientAccentLight,
    canvas: background,
  );

  static const ConsoleAccent agency = ConsoleAccent(
    base: agencyAccent,
    dark: agencyAccentDark,
    light: agencyAccentLight,
    canvas: agencyCanvas,
  );

  static const ConsoleAccent admin = ConsoleAccent(
    base: adminAccent,
    dark: adminAccentDark,
    light: adminAccentLight,
    canvas: adminCanvas,
  );

  /// The identity to paint the app in for [role].
  ///
  /// An unrecognised or absent role gets the brand colours. This intentionally
  /// does not throw the way [consoleForRole] does: deciding whether a role is
  /// served at all is that function's job, and a role it has already turned
  /// down should not also be able to break the theme on its way out.
  static ConsoleAccent accentForRole(String? role) {
    switch (role) {
      case 'ADMIN':
        return admin;

      case 'AGENCY_STAFF':
        return agency;

      default:
        return client;
    }
  }
}

/// The three shades one console's chrome is built from.
@immutable
class ConsoleAccent {
  const ConsoleAccent({
    required this.base,
    required this.dark,
    required this.light,
    required this.canvas,
  });

  /// Selected navigation icons and labels.
  final Color base;

  /// The darker shade, for accent text that has to hold its own against a
  /// light canvas.
  final Color dark;

  /// The lighter shade, for the navigation indicator and other tints.
  final Color light;

  /// The flat colour behind screens that do not paint a wash of their own.
  final Color canvas;

  @override
  bool operator ==(Object other) {
    return other is ConsoleAccent &&
        other.base == base &&
        other.dark == dark &&
        other.light == light &&
        other.canvas == canvas;
  }

  @override
  int get hashCode => Object.hash(base, dark, light, canvas);

  @override
  String toString() => 'ConsoleAccent(base: $base, canvas: $canvas)';
}

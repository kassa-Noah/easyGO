import 'package:flutter/material.dart';

enum AppLanguage { english, french }

class AppSettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  AppLanguage _language = AppLanguage.english;

  ThemeMode get themeMode => _themeMode;

  AppLanguage get language => _language;

  Locale get locale {
    switch (_language) {
      case AppLanguage.english:
        return const Locale('en');

      case AppLanguage.french:
        return const Locale('fr');
    }
  }

  bool get isEnglish => _language == AppLanguage.english;

  bool get isFrench => _language == AppLanguage.french;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;

    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) {
      return;
    }

    _language = language;

    notifyListeners();
  }
}

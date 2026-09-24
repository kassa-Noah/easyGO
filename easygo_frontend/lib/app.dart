import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/settings/app_settings_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';

class EasyGoApp extends StatefulWidget {
  const EasyGoApp({
    super.key,
  });

  @override
  State<EasyGoApp> createState() =>
      _EasyGoAppState();
}

class _EasyGoAppState
    extends State<EasyGoApp> {
  final AppSettingsController
      _settingsController =
      AppSettingsController();

  @override
  void dispose() {
    _settingsController.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedBuilder(
      animation:
          _settingsController,
      builder: (
        context,
        child,
      ) {
        return AppSettingsScope(
          controller:
              _settingsController,
          child: MaterialApp(
            debugShowCheckedModeBanner:
                false,

            title:
                AppStrings.appName,

            theme:
                AppTheme.lightTheme,

            darkTheme:
                AppTheme.darkTheme,

            themeMode:
                _settingsController
                    .themeMode,

            themeAnimationDuration:
                const Duration(
              milliseconds: 350,
            ),

            themeAnimationCurve:
                Curves.easeInOut,

            locale:
                _settingsController
                    .locale,

            supportedLocales:
                AppLocalizations
                    .supportedLocales,

            localizationsDelegates:
                const [
              AppLocalizations
                  .delegate,
              GlobalMaterialLocalizations
                  .delegate,
              GlobalWidgetsLocalizations
                  .delegate,
              GlobalCupertinoLocalizations
                  .delegate,
            ],

            home:
                const SplashScreen(),
          ),
        );
      },
    );
  }
}
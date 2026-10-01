import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/navigation/app_navigator.dart';
import 'core/push/push_service.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/settings/app_settings_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/services/auth_service.dart';

class EasyGoApp extends StatefulWidget {
  const EasyGoApp({super.key});

  @override
  State<EasyGoApp> createState() => _EasyGoAppState();
}

class _EasyGoAppState extends State<EasyGoApp> {
  final AppSettingsController _settingsController = AppSettingsController();

  /// Lets a push that arrives while the app is open be shown from outside any
  /// screen's build. Android draws nothing for a foregrounded app, so without a
  /// messenger reachable from here the reader would see nothing at all.
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Everything that should re-theme the whole app: a change of theme or
  /// locale, and a change of signed-in account.
  ///
  /// Held rather than rebuilt per build, so the listener wiring is not torn
  /// down and put back on every rebuild.
  late final Listenable _themeTrigger = Listenable.merge(<Listenable>[
    _settingsController,
    AuthService.instance.signedInRole,
  ]);

  @override
  void initState() {
    super.initState();

    PushService.onForegroundMessage = _showForegroundPush;
    PushService.onNotificationOpened = AppNavigator.openNotifications;
  }

  @override
  void dispose() {
    PushService.onForegroundMessage = null;
    PushService.onNotificationOpened = null;

    _settingsController.dispose();

    super.dispose();
  }

  /// Shows a push that arrived while the app was already open.
  ///
  /// A banner rather than a system notification, because a system notification
  /// for something the reader is already looking at is noise. The same event is
  /// also in the bell, which is where the reader would act on it.
  void _showForegroundPush(String title, String body) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(body),
            ],
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeTrigger,
      builder: (context, child) {
        // Read inside the builder, not captured outside it: the whole point is
        // that signing in moves the app into the console's colours without a
        // restart, and a value captured before the listener ran would not.
        final ConsoleAccent accent = AppColors.accentForRole(
          AuthService.instance.signedInRole.value,
        );

        return AppSettingsScope(
          controller: _settingsController,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,

            // A push is handled by code that has no `BuildContext`, so the
            // navigator has to be reachable from outside a widget.
            navigatorKey: AppNavigator.key,

            scaffoldMessengerKey: _messengerKey,

            title: AppStrings.appName,

            theme: AppTheme.lightThemeFor(accent),

            darkTheme: AppTheme.darkThemeFor(accent),

            themeMode: _settingsController.themeMode,

            themeAnimationDuration: const Duration(milliseconds: 350),

            themeAnimationCurve: Curves.easeInOut,

            locale: _settingsController.locale,

            supportedLocales: AppLocalizations.supportedLocales,

            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}

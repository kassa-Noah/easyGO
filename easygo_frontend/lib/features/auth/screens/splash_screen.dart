import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/push/push_service.dart';
import '../console_for_role.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService.instance;

  Timer? _navigationTimer;

  /// The session check, started as the screen appears rather than when the
  /// branding ends.
  ///
  /// Restoring a session is a network round trip. Waiting for the three seconds
  /// of branding and only then asking would add the two together; starting now
  /// means the answer is usually waiting by the time the logo has finished.
  late final Future<AuthUser?> _session;

  @override
  void initState() {
    super.initState();

    _session = _authService.restoreSession();

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      _continue();
    });
  }

  /// Where the app goes once the branding has been shown.
  ///
  /// A session that is already signed in goes straight to its console. Asking
  /// the reader to sign in on every launch was the behaviour, and it also cost
  /// the first half of a push: a notification tapped from a cold start arrived
  /// before there was any console to open it over.
  Future<void> _continue() async {
    final AuthUser? user = await _session;

    if (!mounted) {
      return;
    }

    final Widget? console = user == null ? null : consoleForRole(user.role);

    if (console == null) {
      // Nobody is signed in, or the account's role is one this build does not
      // serve. A session it cannot use is signed out of rather than left to
      // fail later, and it never releases the device token on the way — that
      // release is an authenticated call and the token is still valid here.
      if (user != null) {
        await _authService.logout();

        if (!mounted) {
          return;
        }
      }

      _go(const OnboardingScreen());

      return;
    }

    // A restored session is still a session, so the device registers for push
    // again. The token can have been rotated while the app was closed, and
    // without a sign-in this is the only point at which that is noticed.
    unawaited(PushService.instance.start());

    _go(console);

    // A push can be what started the app. There is a console now, so it can be
    // opened over it — which is the point the payload was being sent for.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (PushService.takeOpenedFromPush()) {
        AppNavigator.openNotifications();
      }
    });
  }

  void _go(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The first frame of the app, so it follows the theme. It used to be
    // hardcoded white, which meant a bright flash before a dark app.
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The branding is centred when there is enough room and
            // scrolls on short screens so that nothing is clipped.
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppAssets.logo,
                          width: 210,
                          height: 210,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 24),

                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          AppStrings.tagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 48),

                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: colors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

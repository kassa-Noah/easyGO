import 'package:flutter/material.dart';

import '../../features/notifications/screens/notifications_screen.dart';

/// Navigation that has to happen from outside a widget's build.
///
/// A push is delivered to the app, not to a screen, so the code that handles one
/// has no `BuildContext` and nothing to push with. The same is true of the
/// sign-in flow, which finishes by replacing the whole stack and then has no
/// context of its own left to push onto.
///
/// This file knows about `NotificationsScreen`, which is normally the wrong way
/// round — core should not import a feature. It is here because the alternative
/// is the same three lines in two places, and the one thing both places must
/// agree on is *where tapping a push goes*. One function is a better place for
/// that agreement than two that happen to match.
class AppNavigator {
  const AppNavigator._();

  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  /// Opens the notifications, on top of whatever the reader is looking at.
  ///
  /// On top rather than replacing: the reader was somewhere, and a push is an
  /// interruption rather than a decision to leave that place.
  ///
  /// The notification list rather than the record the push names. The list
  /// already resolves a reference and the reader's role to a destination, and it
  /// is where the same event is also waiting to be read — so going through it
  /// costs one tap and keeps a single place that decides where a notification
  /// leads.
  ///
  /// Returns whether there was anywhere to navigate to, so a caller can tell the
  /// difference between "opened it" and "there was no app yet".
  static bool openNotifications() {
    final NavigatorState? navigator = key.currentState;

    if (navigator == null) {
      return false;
    }

    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
    );

    return true;
  }
}

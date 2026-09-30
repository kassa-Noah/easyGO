import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';

/// Push notifications, from the phone's side.
///
/// The server writes a notification and sends a push alongside it. This is the
/// half that asks the phone for permission, tells the server where to send, and
/// takes the token back when the account signs out.
///
/// Every method here is deliberately quiet. Push is an extra way of being told
/// something the app already knows, so a phone that cannot be pushed to — an
/// emulator without Google Play services, a build with no Firebase config, a
/// reader who declined — must be indistinguishable from any other in how the app
/// behaves. Nothing in this file can throw at a caller or block a sign-in.
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  final ApiClient _apiClient = ApiClient.instance;

  /// Whether this build can be pushed to at all.
  ///
  /// Android and iOS only. On the web a push needs a service worker and a VAPID
  /// key, which is a different piece of work, and it would quietly do nothing
  /// here while looking as though it should.
  static bool get isSupported {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Set once by the app, so a push that arrives while the app is open can be
  /// shown.
  ///
  /// Android does not draw a notification for a foregrounded app, so without
  /// this the reader would see nothing at all: the phone would not buzz and no
  /// banner would appear. The alternative is a local-notifications plugin, which
  /// is another native dependency to configure and verify for one banner.
  static void Function(String title, String body)? onForegroundMessage;

  /// Set once by the app, for a push the reader has tapped.
  ///
  /// This is the other half of sending a `referenceType` and `referenceId` with
  /// the push: the payload exists so that opening a push leads somewhere, and
  /// without this it was carried, delivered and thrown away.
  static void Function()? onNotificationOpened;

  /// Whether the app was started by a tap on a push, and that has not been
  /// honoured yet.
  ///
  /// The app is launched by a push into the splash screen and then the sign-in
  /// screen, so there is no console to open the notification list over at the
  /// moment the push arrives. The sign-in flow collects this instead, which is
  /// the first point at which there is somewhere to go.
  static bool _openedFromPush = false;

  /// Whether the app was started by a tap on a push, consumed as it is read.
  ///
  /// One call rather than a getter beside a separate acknowledgement, so the
  /// sign-in flow cannot read the flag and forget to clear it. If it did, the
  /// notification list would reopen on every later sign-in.
  static bool takeOpenedFromPush() {
    final bool opened = _openedFromPush;

    _openedFromPush = false;

    return opened;
  }

  /// Puts the service in the state a push would have left it in.
  ///
  /// `getInitialMessage` is the only thing that sets the flag, and it needs
  /// Firebase and a real push to open the app, so this is the only way to reach
  /// that state from a test. The behaviour behind it — consumed exactly once —
  /// is real, so the seam is worth having.
  @visibleForTesting
  static void debugSetOpenedFromPush(bool value) {
    _openedFromPush = value;
  }

  bool _firebaseReady = false;
  bool _listening = false;

  /// Whether an account is signed in, which decides whether a tapped push has
  /// anywhere to go. The sign-in screen has no console to open the list over.
  bool _signedIn = false;

  /// The token this device was last registered with, so signing out can release
  /// exactly this device rather than every device the account uses.
  String? _registeredToken;

  /// Starts Firebase once, before the app runs.
  ///
  /// Called from `main`. A failure is not fatal and is not rethrown: a build
  /// without `google-services.json`, or an iOS build without
  /// `GoogleService-Info.plist`, still runs the whole app, it just cannot be
  /// pushed to.
  static Future<void> initialize() async {
    if (!isSupported) {
      return;
    }

    try {
      await Firebase.initializeApp();

      instance._firebaseReady = true;

      // The app can be started *by* a tap on a push, from a state where it was
      // not running at all. Firebase hands that one message back here, once.
      //
      // It is read during start-up rather than later because that is the only
      // point at which it is guaranteed to still be available; it is acted on
      // much later, after sign-in, because that is the first point at which
      // there is anything to open.
      final RemoteMessage? launched =
          await FirebaseMessaging.instance.getInitialMessage();

      if (launched != null) {
        _openedFromPush = true;
      }
    } catch (error) {
      debugPrint(
        'Push is unavailable on this build, so notifications stay in the app: '
        '$error',
      );
    }
  }

  /// Asks to be pushed to, and tells the server where.
  ///
  /// Called after a successful sign-in. Safe to call more than once: the token
  /// is re-registered rather than duplicated, which also picks up a token
  /// Firebase rotated while the app was closed.
  Future<void> start() async {
    // Recorded before the Firebase check, because whether an account is signed
    // in is a fact about the app rather than about push.
    _signedIn = true;

    if (!_firebaseReady) {
      return;
    }

    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Android 13 and later show nothing until the reader has agreed, and the
      // request has to come from the app rather than from the manifest.
      await messaging.requestPermission();

      final String? token = await messaging.getToken();

      if (token != null && token.isNotEmpty) {
        await _register(token);
      }

      _attachListeners();
    } catch (error) {
      debugPrint('Unable to set this device up for push notifications: $error');
    }
  }

  /// Stops pushing to this device.
  ///
  /// Called on sign-out, *before* the access token is cleared, because the
  /// request has to be authenticated. Without it a signed-out phone keeps
  /// receiving the notifications of whichever account left it.
  Future<void> stop() async {
    _signedIn = false;

    final String? token = _registeredToken;

    _registeredToken = null;

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await _apiClient.delete(
        '/devices/tokens/${Uri.encodeComponent(token)}',
        authenticated: true,
      );
    } on ApiException catch (error) {
      // The device stays registered and may receive one more notification than
      // it should. Signing out must still succeed.
      debugPrint('Unable to release this device from push notifications: $error');
    }
  }

  Future<void> _register(String token) async {
    try {
      await _apiClient.post(
        '/devices/tokens',
        authenticated: true,
        body: <String, dynamic>{'token': token, 'platform': _platformName()},
      );

      _registeredToken = token;
    } on ApiException catch (error) {
      debugPrint('Unable to register this device for push notifications: $error');
    }
  }

  /// Both listeners, attached once.
  ///
  /// Guarded together rather than separately: a second sign-in would otherwise
  /// leave the token-refresh listener alone but add a second foreground
  /// listener, and every push that arrived while the app was open would show
  /// two banners.
  void _attachListeners() {
    if (_listening) {
      return;
    }

    _listening = true;

    // Firebase retires a token when the app is reinstalled, restored onto
    // another device, or its data is cleared, and issues a new one. Without
    // this the new token is not registered until the next sign-in, and pushes
    // go nowhere in between.
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _register(token);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String title = message.notification?.title ?? '';
      final String body = message.notification?.body ?? '';

      if (title.isEmpty && body.isEmpty) {
        return;
      }

      onForegroundMessage?.call(title, body);
    });

    // The reader tapped a push while the app was in the background. This is the
    // case the payload was sent for: without it, a push opened the app wherever
    // it happened to be rather than at the thing it was about.
    //
    // Ignored when nobody is signed in, because the only screen showing is the
    // sign-in screen and a notification list over it would be an error. The
    // cold-start case is collected after sign-in instead, through
    // `openedFromPush`.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!_signedIn) {
        return;
      }

      onNotificationOpened?.call();
    });
  }

  String _platformName() {
    return defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID';
  }
}

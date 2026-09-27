import 'package:flutter/foundation.dart';

/// Where the Google Maps key comes from, and whether there is one.
///
/// The key is never written into the repository. It is supplied at build time:
///
/// ```
/// flutter run --dart-define=GOOGLE_MAPS_API_KEY=your-key
/// ```
///
/// On the web there is a second half to this that no build flag can cover: the
/// Maps JavaScript API has to be loaded by a `<script>` tag in `web/index.html`
/// before the app builds a map, because the browser is what loads the SDK. The
/// README describes it. A web key is visible to anyone who opens dev tools —
/// that is how Google Maps works — so it is restricted by HTTP referrer in the
/// Google Cloud console rather than hidden.
///
/// A key can be restricted per platform (an Android key does not work on iOS,
/// and neither works on the web), which is why the platform is reported
/// alongside the key: a map that fails for a platform-specific reason should
/// say so rather than send the reader looking for the wrong problem.
class MapsConfig {
  const MapsConfig._();

  static const String _key = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static String get apiKey => _key.trim();

  /// Whether a map can be built at all on this platform.
  ///
  /// A build with no key is a normal state, not a failure: the screens show the
  /// coordinates and say what is missing.
  static bool get isConfigured => apiKey.isNotEmpty;

  /// Where the key is expected to be supplied, for the message shown when it is
  /// not.
  static String get platformLabel {
    if (kIsWeb) {
      return 'web';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'Android'
        : 'iOS or macOS';
  }

  /// What the reader has to do to see a map.
  static String get setupHint {
    if (kIsWeb) {
      return 'Add your key to the Google Maps script tag in web/index.html, '
          'and pass the same value with '
          '--dart-define=GOOGLE_MAPS_API_KEY=... so the app knows to build '
          'the map.';
    }

    return 'Run the app with --dart-define=GOOGLE_MAPS_API_KEY=... using a key '
        'that is enabled for $platformLabel.';
  }
}

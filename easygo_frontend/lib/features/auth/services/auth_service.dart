import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import '../../../core/push/push_service.dart';
import '../models/auth_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiClient _apiClient = ApiClient.instance;

  final TokenStorage _tokenStorage = TokenStorage.instance;

  /// The role of the account whose token is stored, or null when signed out.
  ///
  /// The app listens to this so it can paint itself in that console's colours.
  /// It is session state rather than a preference, which is why it lives here
  /// and not in the settings controller: a setting outlives a session, and this
  /// one must not — signing out has to take the colour with it.
  final ValueNotifier<String?> signedInRole = ValueNotifier<String?>(null);

  /// Records [user] as the account this session belongs to.
  ///
  /// Every path that leaves a token in the store goes through here, which is
  /// the only reason the accent and the session cannot disagree.
  AuthUser _rememberRole(AuthUser user) {
    signedInRole.value = user.role;

    return user;
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final dynamic response = await _apiClient.post(
      '/auth/login',
      body: {'email': email.trim(), 'password': password},
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'Authentication data is missing.');
    }

    final dynamic token = data['token'];
    final dynamic user = data['user'];

    if (token is! String || token.isEmpty || user is! Map) {
      throw const ApiException(message: 'Invalid authentication response.');
    }

    await _tokenStorage.saveToken(token);

    return _rememberRole(AuthUser.fromJson(Map<String, dynamic>.from(user)));
  }

  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final dynamic response = await _apiClient.post(
      '/auth/register',
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
      },
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'Registration data is missing.');
    }

    final dynamic token = data['token'];
    final dynamic nestedUser = data['user'];

    if (token is String && token.isNotEmpty && nestedUser is Map) {
      await _tokenStorage.saveToken(token);

      return _rememberRole(
        AuthUser.fromJson(Map<String, dynamic>.from(nestedUser)),
      );
    }

    if (nestedUser is Map) {
      // Registered but not signed in, so there is no session to carry a
      // console colour yet.
      return AuthUser.fromJson(Map<String, dynamic>.from(nestedUser));
    }

    return AuthUser.fromJson(Map<String, dynamic>.from(data));
  }

  Future<AuthUser> getCurrentUser() async {
    final dynamic response = await _apiClient.get(
      '/users/me',
      authenticated: true,
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'User information is missing.');
    }

    return _rememberRole(AuthUser.fromJson(Map<String, dynamic>.from(data)));
  }

  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final dynamic response = await _apiClient.patch(
      '/users/me',
      authenticated: true,
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
      },
    );

    if (response is! Map) {
      throw const ApiException(
        message: 'Invalid response received from the server.',
      );
    }

    final dynamic data = response['data'];

    if (data is! Map) {
      throw const ApiException(message: 'Updated user information is missing.');
    }

    return AuthUser.fromJson(Map<String, dynamic>.from(data));
  }

  /// Replaces the signed-in account's password.
  ///
  /// The account is taken from the access token on the server, so this can only
  /// ever change the caller's own password. The current password is required as
  /// proof that the caller is the account holder and not a borrowed session.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/auth/change-password',
      authenticated: true,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<bool> isLoggedIn() {
    return _tokenStorage.hasToken();
  }

  /// The account the stored token belongs to, when that token still works.
  ///
  /// Returns null both when nobody is signed in and when the server has rejected
  /// the token. Those are the same thing to the reader, with one difference that
  /// matters: a rejected token is cleared so it is not presented again, and a
  /// token that simply could not be checked is kept.
  ///
  /// Keeping it is the point. Clearing on any failure would sign the reader out
  /// — and lose the device's push registration with it — because a server was
  /// restarting or a phone had a moment of no signal.
  Future<AuthUser?> restoreSession() async {
    final bool hasToken;

    try {
      hasToken = await _tokenStorage.hasToken();
    } catch (_) {
      // The token store could not be read, so there is no token to restore. It
      // is caught rather than allowed out because this runs at start-up: a
      // platform that cannot read its secure storage must start the app signed
      // out, not crash it before the first frame.
      return null;
    }

    if (!hasToken) {
      return null;
    }

    try {
      return await getCurrentUser();
    } on ApiException catch (error) {
      // Only a rejection means the token is no good.
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _tokenStorage.deleteToken();

        // The token was refused, so the console the previous session was in is
        // not this session's console.
        signedInRole.value = null;
      }

      return null;
    }
  }

  Future<void> logout() async {
    // Before the token is cleared, because releasing the device is an
    // authenticated call and there will be nothing left to authenticate with
    // afterwards. Without it the phone keeps receiving the notifications of the
    // account that just signed out, which is a privacy problem rather than an
    // inconvenience.
    await PushService.instance.stop();

    await _tokenStorage.deleteToken();

    // Last, so a rebuild triggered by this cannot see a token that is already
    // gone and still paint the old console's colours.
    signedInRole.value = null;
  }
}

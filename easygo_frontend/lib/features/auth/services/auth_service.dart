import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import '../models/auth_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiClient _apiClient = ApiClient.instance;

  final TokenStorage _tokenStorage = TokenStorage.instance;

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

    return AuthUser.fromJson(Map<String, dynamic>.from(user));
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

      return AuthUser.fromJson(Map<String, dynamic>.from(nestedUser));
    }

    if (nestedUser is Map) {
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

    return AuthUser.fromJson(Map<String, dynamic>.from(data));
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

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }
}

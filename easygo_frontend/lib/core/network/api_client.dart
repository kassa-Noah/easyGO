import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();

  final TokenStorage _tokenStorage = TokenStorage.instance;

  Future<Map<String, String>> _buildHeaders({
    bool authenticated = false,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final String? token = await _tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw const ApiException(
          message: 'Authentication token is missing.',
          statusCode: 401,
        );
      }

      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final String normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$normalizedEndpoint');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final Map<String, String> normalizedQuery = {};

    queryParameters.forEach((String key, dynamic value) {
      if (value != null) {
        normalizedQuery[key] = value.toString();
      }
    });

    return uri.replace(queryParameters: normalizedQuery);
  }

  Future<dynamic> get(
    String endpoint, {
    bool authenticated = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Uri uri = _buildUri(endpoint, queryParameters);

      final http.Response response = await _client
          .get(uri, headers: await _buildHeaders(authenticated: authenticated))
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(message: 'Unable to connect to the server.');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    bool authenticated = false,
    Map<String, dynamic>? body,
  }) async {
    try {
      final http.Response response = await _client
          .post(
            _buildUri(endpoint),
            headers: await _buildHeaders(authenticated: authenticated),
            body: jsonEncode(body ?? {}),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(message: 'Unable to connect to the server.');
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    bool authenticated = false,
    Map<String, dynamic>? body,
  }) async {
    try {
      final http.Response response = await _client
          .patch(
            _buildUri(endpoint),
            headers: await _buildHeaders(authenticated: authenticated),
            body: jsonEncode(body ?? {}),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(message: 'Unable to connect to the server.');
    }
  }

  Future<dynamic> delete(String endpoint, {bool authenticated = false}) async {
    try {
      final http.Response response = await _client
          .delete(
            _buildUri(endpoint),
            headers: await _buildHeaders(authenticated: authenticated),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(message: 'Unable to connect to the server.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decodedBody;

    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    String message = 'An unexpected server error occurred.';

    if (decodedBody is Map) {
      final dynamic backendMessage = decodedBody['message'];

      if (backendMessage is String && backendMessage.isNotEmpty) {
        message = backendMessage;
      }

      final dynamic backendError = decodedBody['error'];

      if (backendError is String &&
          backendError.isNotEmpty &&
          (backendMessage == null || backendMessage.toString().isEmpty)) {
        message = backendError;
      }
    }

    throw ApiException(message: message, statusCode: response.statusCode);
  }

  void close() {
    _client.close();
  }
}

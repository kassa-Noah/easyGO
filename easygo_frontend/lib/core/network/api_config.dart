import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web / Chrome runs directly
      // on the development computer.
      return 'http://localhost:5000/api';
    }

    // Android emulator uses 10.0.2.2
    // to access the host computer's localhost.
    return 'http://10.0.2.2:5000/api';
  }

  static const Duration timeout =
      Duration(seconds: 20);
}
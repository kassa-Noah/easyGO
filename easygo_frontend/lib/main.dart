import 'package:flutter/material.dart';

import 'app.dart';
import 'core/push/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Starts Firebase when the platform can be pushed to, and does nothing
  // anywhere else. It cannot throw: a build with no Firebase configuration runs
  // the whole app and simply cannot be pushed to.
  await PushService.initialize();

  runApp(const EasyGoApp());
}

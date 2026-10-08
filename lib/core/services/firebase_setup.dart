import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../constants/app_environment.dart';
import '../utils/app_logger.dart';

/// Brings Firebase up once, before anything that uses it is built.
///
/// Never throws: a build without Firebase config, or a phone without Play
/// services, must still open the app — every Firebase-backed service falls
/// back to a no-op when [ready] is false.
abstract final class FirebaseSetup {
  static bool ready = false;

  static Future<void> init() async {
    if (!AppEnvironment.firebaseEnabled) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      ready = true;
    } on Object catch (e, s) {
      AppLogger.e(
        'Firebase did not start; push and crash reports are off',
        e,
        s,
      );
    }
  }
}

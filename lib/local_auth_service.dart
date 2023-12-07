import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

/*
    Class handles biometric authentication for
    entry into the app
 */

class LocalAuth {
  static final _auth = LocalAuthentication();

  //check if device is supported
  static Future<bool> _canAuthenticate() async =>
      await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  static Future<bool> authenticate() async {
    try {
      if (!await _canAuthenticate()) return false;

      return await _auth.authenticate(
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Sign in',
            cancelButton: 'No Thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          )
        ],
        localizedReason: 'Use biometrics to grant access',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
        )
      );
    } catch(e) {
//      debugPrint('Error during authentication: $e');
      return false;
    }
  }
}
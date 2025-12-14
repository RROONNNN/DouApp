import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleConfig {
  static String get serverClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';

  static String? get androidClientId => dotenv.env['GOOGLE_ANDROID_CLIENT_ID'];
  static String? get iosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'];
}

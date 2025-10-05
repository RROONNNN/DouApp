import 'package:duo_app/data/local/shared_prefs.dart';
import 'package:duo_app/data/local/shared_prefs_key.dart';
import 'package:injectable/injectable.dart';

abstract class LocalService {
  String getToken();
  void saveToken(String token);
  String getRefreshToken();
  void saveRefreshToken(String refreshToken);
}

@LazySingleton(as: LocalService)
class LocalServiceImplement extends LocalService {
  final SharedPrefs _sharedPrefs;
  LocalServiceImplement(this._sharedPrefs);

  @override
  String getToken() {
    return _sharedPrefs.get(SharedPrefsKey.token);
  }

  @override
  void saveToken(String token) {
    _sharedPrefs.put(SharedPrefsKey.token, token);
  }

  @override
  String getRefreshToken() {
    return _sharedPrefs.get(SharedPrefsKey.refreshToken);
  }

  @override
  void saveRefreshToken(String refreshToken) {
    _sharedPrefs.put(SharedPrefsKey.refreshToken, refreshToken);
  }
}

import 'package:duo_app/data/local/shared_prefs.dart';
import 'package:duo_app/data/local/shared_prefs_key.dart';
import 'package:injectable/injectable.dart';

abstract class LocalService {}

@LazySingleton(as: LocalService)
class LocalServiceImplement extends LocalService {
  final SharedPrefs _sharedPrefs;
  LocalServiceImplement(this._sharedPrefs);
}

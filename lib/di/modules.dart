import 'dart:convert';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class InjectableModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  Dio get dio => Dio();

  @preResolve
  @Named('cookieJar')
  Future<PersistCookieJar> get cookieJar async {
    final appDir = await getApplicationDocumentsDirectory();
    final path = '${appDir.path}/.cookies';
    final storage = FileStorage('$path/encryption')
      ..readPreHandler = (Uint8List list) {
        return utf8.decode(list.map<int>((e) => e ^ 2).toList());
      }
      ..writePreHandler = (String value) {
        return utf8.encode(value).map<int>((e) => e ^ 2).toList();
      };
    return PersistCookieJar(storage: storage);
  }
}

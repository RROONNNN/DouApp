import 'package:duo_app/data/remote/api_endpoint.dart';
import 'package:injectable/injectable.dart';

abstract class BuildConfig {
  bool get debugLog;

  String get kBaseUrl;

  String get kBaseImageUrl;

  String get kDefaultAppName;

  String get kAppStoreUrl;

  String get kPlayStoreUrl;

  String get kakaoApiKey;
}

@LazySingleton(as: BuildConfig)
class BuildConfigProd implements BuildConfig {
  final String _baseUrl = ApiEndpoint.baseUrl;
  @override
  String get kBaseUrl => _baseUrl;
  @override
  bool debugLog = true;

  // @override
  // String kBaseUrl = 'http://124.158.10.164:32133';

  @override
  String kBaseImageUrl = '';
  @override
  String kDefaultAppName = '';

  @override
  String kAppStoreUrl = '';

  @override
  String kPlayStoreUrl = '';

  @override
  String kakaoApiKey = '';
}

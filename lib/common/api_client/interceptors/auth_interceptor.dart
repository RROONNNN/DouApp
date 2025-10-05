import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:duo_app/common/api_client/api_client.dart';
import 'package:duo_app/data/local/shared_prefs.dart';
import 'package:duo_app/data/local/shared_prefs_key.dart';
import 'package:duo_app/data/remote/authentication/login_response.dart';
import 'package:duo_app/route/navigator.dart';

import '../../../data/remote/api_endpoint.dart';
import '../../../di/injection.dart';
import '../../../route/app_route.dart';
import '../../event/event_bus_event.dart';
import '../../event/event_bus_mixin.dart';

class AuthInterceptor extends Interceptor with EventBusMixin {
  final SharedPrefs _sharedPrefs = getIt<SharedPrefs>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = _sharedPrefs.get(SharedPrefsKey.token);
    if (token != null && !options.path.contains(ApiEndpoint.login)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = _sharedPrefs.get(SharedPrefsKey.refreshToken);
        if (refreshToken != null) {
          final ApiClient apiClient = getIt<ApiClient>();
          final response = await apiClient.post(
              path: ApiEndpoint.refresh, data: {'refresh_token': refreshToken});
          if (response.isSuccess()) {
            LoginResponse loginResponse =
                LoginResponse.fromJson(response.value);
            _sharedPrefs.put(SharedPrefsKey.token, loginResponse.accessToken);
            _sharedPrefs.put(
                SharedPrefsKey.refreshToken, loginResponse.refreshToken);
            err.requestOptions.headers['Authorization'] =
                'Bearer ${loginResponse.accessToken}';
            return super.onError(err, handler);
          }
          throw Exception('Refresh token failed');
        }
      } catch (e) {
        log('AuthInterceptor error: ${e.toString()}');
      } finally {
        shareEvent(LogoutEvent());
        AppNavigator.pushNamedAndRemoveUntil(RouterName.login, (r) => false);
      }
    }
    super.onError(err, handler);
  }
}

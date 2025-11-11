import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:duo_app/common/api_client/interceptors/cookie_interceptor.dart';
import 'package:duo_app/common/api_client/interceptors/curl_logger_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../configs/build_config.dart';
import '../../di/injection.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';

@Singleton()
class ApiClient {
  final PersistCookieJar cookieJar;
  ApiClient({required this.dio, @Named('cookieJar') required this.cookieJar}) {
    final BuildConfig buildConfig = getIt<BuildConfig>();
    dio.options.baseUrl = buildConfig.kBaseUrl;

    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(CookieInterceptor(cookieJar));
    dio.interceptors.add(CurlLoggerDioInterceptor());
    if (buildConfig.debugLog) {
      dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }
    _config();
  }
  void _config() {
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['client-id'] = Platform.isAndroid ? 'Android' : 'iOS';
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 20);
  }

  final _defaultHeaders = {
    "Content-Type": "application/json",
    'Accept': 'application/json',
  };

  final Dio dio;

  void updateConfigBaseUrl(String url) {
    dio.options.baseUrl = url;
  }

  Future<ApiResponse> post({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    bool isNotContentType = false,
  }) async {
    final requestHeaders = headers ?? _defaultHeaders;
    if (isNotContentType) {
      requestHeaders.remove('Content-Type');
      dio.options.headers.remove('Content-Type');
    }
    dio.options.headers.addAll(requestHeaders);

    return responseWrapper(
      dio.post<dynamic>(
        path,
        data: data,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<ApiResponse> put({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    dio.options.headers.addAll(headers ?? {});
    return responseWrapper(dio.put<dynamic>(path, data: data));
  }

  Future<ApiResponse> patch({required String path, dynamic data}) async {
    return responseWrapper(dio.patch<dynamic>(path, data: data));
  }

  Future<ApiResponse> delete({required String path, dynamic data}) async {
    return responseWrapper(dio.delete<dynamic>(path, data: data));
  }

  Future<ApiResponse> get({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    dio.options.headers.addAll(headers ?? {});
    return responseWrapper(
      dio.request<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
        data: data,
      ),
    );
  }

  Future<ApiResponse> download({
    required String path,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await dio.download(path, savePath, onReceiveProgress: onReceiveProgress);
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return _handleRequestError(e);
    }
  }

  Future<ApiResponse> responseWrapper(Future<Response<dynamic>> func) async {
    try {
      final Response<dynamic> response = await func;
      Map<String?, dynamic>? decode;

      if (response.data is Map<String, dynamic>) {
        decode = response.data;
      } else if (response.data is String) {
        try {
          decode = json.decode(response.data);
        } on FormatException {
          return ApiResponse(
            success: response.statusCode == 200,
            data: response.data,
            value: response.data,
          );
        }
      } else {
        decode = response.data;
      }

      if (decode is Map<String?, dynamic>) {
        return ApiResponse.fromJson(decode);
      }
      return ApiResponse(success: false, error: 'Something went wrong');
    } on DioException catch (e) {
      debugPrint('error: $e');
      return _handleRequestError(e);
    } catch (e) {
      debugPrint('responseWrapper error: $e');
      rethrow;
    }
  }

  ApiResponse _handleRequestError(DioException e) {
    try {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse(success: false, error: 'Network error');
      }
      if (e.response == null || e.response?.data == null) {
        return ApiResponse(success: false, error: 'Something went wrong');
      }
      final data = e.response?.data;
      Map<String?, dynamic>? decode;

      if (data is Map<String, dynamic>) {
        decode = data;
      } else if (data is String) {
        decode = json.decode(data);
      } else {
        decode = data;
      }
      return ApiResponse(
        success: false,
        error: decode?['message'] ?? 'Something went wrong',
      );
    } catch (e) {
      return ApiResponse(success: false, error: 'Something went wrong');
    }
  }
}

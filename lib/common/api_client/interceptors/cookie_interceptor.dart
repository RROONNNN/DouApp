import 'dart:async';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class CookieInterceptor extends Interceptor {
  final CookieJar cookieJar;

  CookieInterceptor(this.cookieJar);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    cookieJar
        .loadForRequest(options.uri)
        .then((cookies) {
          var cookie = getCookies(cookies);
          if (cookie.isNotEmpty) {
            options.headers["Cookie"] = cookie;
          }
          handler.next(options);
        })
        .catchError((e, stackTrace) {
          var err = DioException(requestOptions: options, error: e);
          handler.reject(err, true);
        });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _saveCookies(response).then((_) => handler.next(response)).catchError((
      e,
      stackTrace,
    ) {
      var err = DioException(requestOptions: response.requestOptions, error: e);
      handler.reject(err, true);
    });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _saveCookies(err.response!).then((_) => handler.next(err)).catchError((
        e,
        stackTrace,
      ) {
        var err0 = DioException(
          requestOptions: err.response!.requestOptions,
          error: e,
        );

        handler.next(err0);
      });
    } else {
      handler.next(err);
    }
  }

  Future<void> _saveCookies(Response response) async {
    var cookies = response.headers[HttpHeaders.setCookieHeader];

    if (cookies != null) {
      final cookieList = cookies
          .map((str) => Cookie.fromSetCookieValue(str))
          .toList();
      await cookieJar.saveFromResponse(response.requestOptions.uri, cookieList);
    }
  }

  static String getCookies(List<Cookie> cookies) {
    if (cookies.isNotEmpty) {
      return cookies.first.toString();
    }
    return '';
  }
}

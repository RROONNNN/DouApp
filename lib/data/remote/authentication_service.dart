import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:duo_app/data/remote/authentication/register_request.dart';
import 'package:injectable/injectable.dart';

import '../../common/api_client/api_client.dart';
import '../../common/api_client/api_response.dart';
import '../../common/api_client/data_state.dart';
import 'api_endpoint.dart';
import 'authentication/login_request.dart';
import 'authentication/login_response.dart';

abstract class AuthenticationService {
  Future<DataState<bool>> login(LoginRequest data);
  Future<DataState<LoginResponse>> refreshToken(String refreshToken);
  Future<DataState<String>> register(RegisterRequest data);
  Future<DataState<LoginResponse>> verifyEmail(String email, String code);
  Future<DataState<bool>> logout();
  Future<DataState<bool>> forgotPassword(String email);
  Future<DataState<bool>> changePassword(
    String email,
    String code,
    String password,
  );
}

@LazySingleton(as: AuthenticationService)
class AuthenticationServiceImplement extends AuthenticationService {
  AuthenticationServiceImplement(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DataState<bool>> forgotPassword(String email) async {
    try {
      final ApiResponse response = await _apiClient.post(
        path: ApiEndpoint.forgotPassword,
        data: {'email': email},
      );
      if (response.isSuccess()) {
        return const DataSuccess<bool>(true);
      }
      return DataFailed<bool>(response.error);
    } catch (e) {
      return DataFailed<bool>(e.toString());
    }
  }

  @override
  Future<DataState<bool>> changePassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final ApiResponse response = await _apiClient.post(
        path: ApiEndpoint.changePassword,
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
      if (response.isSuccess()) {
        return const DataSuccess<bool>(true);
      }
      return DataFailed<bool>(response.error);
    } catch (e) {
      return DataFailed<bool>(e.toString());
    }
  }

  @override
  Future<DataState<bool>> logout() async {
    try {
      final ApiResponse response = await _apiClient.post(
        path: ApiEndpoint.logout,
      );
      if (response.isSuccess()) {
        return const DataSuccess<bool>(true);
      }
      return DataFailed<bool>(response.error);
    } on DioException catch (e) {
      return DataFailed<bool>(e.message);
    } on Exception catch (e) {
      return DataFailed<bool>(e.toString());
    }
  }

  @override
  Future<DataState<bool>> login(LoginRequest data) async {
    try {
      final ApiResponse response = await _apiClient.post(
        path: ApiEndpoint.login,
        data: data.toJson(),
      );
      if (response.isSuccess()) {
        return const DataSuccess<bool>(true);
      }
      return DataFailed<bool>(response.error);
    } on DioException catch (e) {
      return DataFailed<bool>(e.message);
    } on Exception catch (e) {
      return DataFailed<bool>(e.toString());
    }
  }

  @override
  Future<DataState<String>> register(RegisterRequest data) async {
    try {
      final ApiResponse response = await _apiClient.post(
        path: ApiEndpoint.register,
        data: data.toJson(),
      );
      if (response.isSuccess()) {
        return DataSuccess<String>(response.value['message']);
      }
      return DataFailed<String>(response.error);
    } on DioException catch (e) {
      return DataFailed<String>(e.message);
    } on Exception catch (e) {
      return DataFailed<String>(e.toString());
    }
  }

  @override
  Future<DataState<LoginResponse>> verifyEmail(
    String email,
    String code,
  ) async {
    try {
      final ApiResponse response = await _apiClient.post(
        path: ApiEndpoint.verifyEmail,
        data: {'email': email, 'code': code},
      );
      if (response.isSuccess()) {
        return DataSuccess<LoginResponse>(
          LoginResponse.fromJson(response.value as Map<String, dynamic>),
        );
      }
      return DataFailed<LoginResponse>(response.error);
    } on DioException catch (e) {
      log('AuthenticationServiceImplement verifyEmail error: ${e.message}');
      return DataFailed<LoginResponse>(e.message);
    } on Exception catch (e) {
      log('AuthenticationServiceImplement verifyEmail error: ${e.toString()}');
      return DataFailed<LoginResponse>(e.toString());
    }
  }

  @override
  Future<DataState<LoginResponse>> refreshToken(String refreshToken) async {
    try {
      final ApiResponse response = await _apiClient.post(
        path: ApiEndpoint.refresh,
        data: {'refresh_token': refreshToken},
      );
      if (response.isSuccess()) {
        return DataSuccess<LoginResponse>(
          LoginResponse.fromJson(response.value as Map<String, dynamic>),
        );
      }
      return DataFailed<LoginResponse>(response.error);
    } on DioException catch (e) {
      return DataFailed<LoginResponse>(e.message);
    } on Exception catch (e) {
      return DataFailed<LoginResponse>(e.toString());
    }
  }
}

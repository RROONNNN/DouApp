import 'dart:developer';

import 'package:duo_app/common/api_client/api_client.dart';
import 'package:duo_app/data/remote/api_endpoint.dart';
import 'package:duo_app/entities/course.dart';
import 'package:duo_app/entities/question.dart';
import 'package:duo_app/entities/theory.dart';
import 'package:duo_app/entities/unit.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class LearningService {
  final ApiClient _apiClient;

  LearningService(this._apiClient);

  Future<List<Question>> getQuestions(String lessonId) async {
    try {
      final response = await _apiClient.get(
        path: '${ApiEndpoint.getQuestions}/$lessonId',
      );
      if (response.isSuccess()) {
        final value = response.value as Map<String, dynamic>;
        final questionsJson = value['data'] as List<dynamic>? ?? [];
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      }
      log('getQuestions fail : ${response.error}');
      return [];
    } catch (e) {
      log('Error getQuestions : $e');
      rethrow;
    }
  }

  Future<List<Course>> getCourses({
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        path: ApiEndpoint.getCourses,
        queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber},
      );
      if (response.isSuccess()) {
        final value = response.value as Map<String, dynamic>;
        final coursesJson = value['data'] as List<dynamic>? ?? [];
        return coursesJson.map((json) => Course.fromJson(json)).toList();
      }
      log('getCourses fail : ${response.error}');
      return [];
    } catch (e) {
      log('Error getCourses : $e');
      rethrow;
    }
  }

  Future<List<Unit>> getUnitsByCourseId(
    String courseId, {
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        path: '${ApiEndpoint.getUnitsByCourseId}/$courseId',
        queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber},
      );
      if (response.isSuccess()) {
        final value = response.value as Map<String, dynamic>;
        final unitsJson = value['data']['items'] as List<dynamic>? ?? [];
        return unitsJson.map((json) => Unit.fromJson(json)).toList();
      }
      log('getUnitsByCourseId fail : ${response.error}');
      return [];
    } catch (e) {
      log('Error getUnitsByCourseId : $e');
      rethrow;
    }
  }

  Future<List<Theory>> getTheoriesByUnitId(
    String unitId, {
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        path: '${ApiEndpoint.getTheoriesByUnitId}/$unitId',
        queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber},
      );
      if (response.isSuccess()) {
        final value = response.value as Map<String, dynamic>;
        final theoriesJson = value['data'] as List<dynamic>? ?? [];
        final theories = theoriesJson
            .map((json) => Theory.fromJson(json))
            .toList();
        return theories;
      }
      log('getTheoriesByUnitId fail : ${response.error}');
      return [];
    } catch (e) {
      log('Error getTheoriesByUnitId : $e');
      rethrow;
    }
  }

  Future<bool> patchProgress({
    required String lessonId,
    required String unitId,
    required String courseId,
    required int experiencePoint,
    required int heartCount,
  }) async {
    try {
      final response = await _apiClient.patch(
        path: ApiEndpoint.patchProgress,
        data: {
          'lessonId': lessonId,
          'unitId': unitId,
          'courseId': courseId,
          'experiencePoint': experiencePoint,
          'heartCount': heartCount,
        },
      );
      if (response.isSuccess()) {
        log('patchProgress success');
        return true;
      }
      log('patchProgress fail : ${response.error}');
      return false;
    } catch (e) {
      log('Error patchProgress : $e');
      rethrow;
    }
  }
}

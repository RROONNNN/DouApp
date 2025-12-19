import 'dart:developer';

import 'package:duo_app/common/api_client/api_client.dart';
import 'package:duo_app/data/remote/api_endpoint.dart';
import 'package:duo_app/entities/course.dart';
import 'package:duo_app/entities/lesson.dart';
import 'package:duo_app/entities/progress.dart';
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

  Future<Course> getCourseById(String courseId) async {
    try {
      final response = await _apiClient.get(
        path: '${ApiEndpoint.getCourseById}/$courseId',
      );
      if (response.isSuccess()) {
        final value = response.value as Map<String, dynamic>;
        return Course.fromJson(value);
      }
      log('getCourseById fail : ${response.error}');
      throw Exception('getCourseById fail : ${response.error}');
    } catch (e) {
      log('Error getCourseById : $e');
      rethrow;
    }
  }

  // Future<List<Mistake>> getMistakes() async {
  //   try {
  //     final response = await _apiClient.get(path: ApiEndpoint.getMistakes);
  //     if (response.isSuccess()) {
  //       final value = response.value as Map<String, dynamic>;
  //       final mistakesJson = value['data'] as List<dynamic>? ?? [];
  //       return mistakesJson.map((json) => Mistake.fromJson(json)).toList();
  //     }
  //   } catch (e) {
  //     log('Error getMistakes : $e');
  //     rethrow;
  //   }
  // }

  Future<void> addMistake(List<String> questionId) async {
    try {
      final body = {"wrongAnswer": questionId};
      final response = await _apiClient.post(
        path: ApiEndpoint.getMistakes,
        data: body,
      );
      if (!response.isSuccess()) {
        log('addMistake fail : ${response.error}');
        throw Exception('addMistake fail: ${response.error}');
      }
    } catch (e) {
      log('Error addMistake : $e');
      rethrow;
    }
  }

  Future<void> patchMistakes(List<Map<String, String>> correctAnswers) async {
    try {
      final body = {
        "correctAnswer": correctAnswers
            .map(
              (answer) => {
                "unitId": answer["unitId"],
                "questionId": answer["questionId"],
              },
            )
            .toList(),
      };
      final response = await _apiClient.patch(
        path: ApiEndpoint.patchMistake,
        data: body,
      );
      if (!response.isSuccess()) {
        log('patchMistakes fail : ${response.error}');
        throw Exception('patchMistakes fail: ${response.error}');
      }
    } catch (e) {
      log('Error patchMistakes : $e');
      rethrow;
    }
  }

  Future<List<Map<Unit, List<Question>>>> getMistakes() async {
    try {
      final mistakes = <Map<Unit, List<Question>>>[];
      final response = await _apiClient.get(path: ApiEndpoint.getMistakes);
      if (response.isSuccess()) {
        final value = response.value as Map<String, dynamic>;
        final json = value['data'] as List<dynamic>? ?? [];
        for (var item in json) {
          final unit = Unit.fromJson((item['unit'] as List<dynamic>).first);
          final questions = (item['questions'] as List<dynamic>? ?? [])
              .map((question) => Question.fromJson(question))
              .toList();
          mistakes.add({unit: questions});
        }
        return mistakes;
      }
      return [];
    } catch (e) {
      log('Error getMistakes : $e');
      rethrow;
    }
  }

  Future<Progress?> getProgress() async {
    try {
      final response = await _apiClient.get(path: ApiEndpoint.getProgress);
      if (response.isSuccess()) {
        if (response.value == null) {
          return null;
        }
        final value = response.value as Map<String, dynamic>;
        final progressJson = value as Map<String, dynamic>? ?? {};
        return Progress.fromJson(progressJson);
      }
      log('getProgress fail : ${response.error}');
      return null;
    } catch (e) {
      log('Error getProgress : $e');
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

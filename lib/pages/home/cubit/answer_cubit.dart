import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/remote/learning_service.dart';
import 'package:duo_app/entities/question.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'answer_state.dart';

@injectable
class AnswerCubit extends Cubit<AnswerState> {
  AnswerCubit({required this.learningService}) : super(const AnswerState());
  final LearningService learningService;
  late Queue<Question> _questions;
  late String courseId;
  late String unitId;
  late int experiencePoint;
  late int heartCount;
  late bool isMistake;
  late List<Question> initQuestions;

  Future<void> initialize(
    String? lessonId,
    String? courseId,
    String? unitId,
    int? experiencePoint,
    int heartCount,
    bool isMistake,
    List<Question> initQuestions,
  ) async {
    emit(state.copyWith(status: RequestStatus.requesting));
    try {
      this.courseId = courseId ?? '';
      this.unitId = unitId ?? '';
      this.experiencePoint = experiencePoint ?? 0;
      this.heartCount = heartCount;
      this.isMistake = isMistake;

      if (isMistake) {
        this.initQuestions = initQuestions;
        _questions = Queue.from(initQuestions);
        emit(
          state.copyWith(
            status: RequestStatus.success,
            questions: initQuestions,
            totalQuestions: initQuestions.length,
            currentQuestion: _questions.first,
          ),
        );
        return;
      }

      // For normal lessons (not mistakes), lessonId is required
      if (lessonId == null) {
        emit(
          state.copyWith(
            status: RequestStatus.failed,
            errorMessage: 'Lesson ID is required for normal lessons',
          ),
        );
        return;
      }

      if (heartCount <= 0) {
        emit(state.copyWith(isHeartCountReached: true));
        return;
      }

      final questions = await learningService.getQuestions(lessonId);
      // for test : filter all questions to only have ordering questions
      final orderingQuestions = questions
          .where(
            (question) => question.typeQuestion == TypeQuestion.multipleChoice,
          )
          .toList();
      _questions = Queue.from(orderingQuestions);
      emit(
        state.copyWith(
          status: RequestStatus.success,
          questions: orderingQuestions,
          totalQuestions: orderingQuestions.length,
          currentQuestion: _questions.first,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RequestStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  bool isQuizComplete() {
    return _questions.isEmpty;
  }

  Future<void> answerCorrectly(String questionId) async {
    _questions.removeFirst();
    if (isQuizComplete()) {
      if (state.currentQuestion?.lessonId == null) {
        emit(
          state.copyWith(
            status: RequestStatus.failed,
            errorMessage: 'Lesson ID is null',
          ),
        );
        throw Exception('Lesson ID is null');
      }
      if (!isMistake) {
        await learningService.patchProgress(
          lessonId: state.currentQuestion?.lessonId ?? '',
          unitId: unitId,
          courseId: courseId,
          experiencePoint: 10,
          heartCount: heartCount,
        );
      } else {
        await learningService.patchMistakes([
          {"unitId": unitId, "questionId": questionId},
        ]);
      }
      emit(state.copyWith(isQuizComplete: true));
      return;
    }
    emit(
      state.copyWith(
        currentQuestion: _questions.first,
        answeredCorrectly: state.answeredCorrectly + 1,
      ),
    );
  }

  Future<void> answerIncorrectly(String questionId) async {
    if (!isMistake) {
      heartCount -= 1;
      if (heartCount <= 0) {
        await learningService.patchProgress(
          lessonId: state.currentQuestion?.lessonId ?? '',
          unitId: unitId,
          courseId: courseId,
          experiencePoint: 10,
          heartCount: 0,
        );

        emit(state.copyWith(isHeartCountReached: true));

        return;
      }
    }

    final question = _questions.firstWhere(
      (question) => question.id == questionId,
    );
    _questions.removeFirst();
    _questions.add(question);
    emit(state.copyWith(currentQuestion: _questions.first));
  }

  void resetQuiz(String questionId) {
    _questions = Queue.from(state.questions);
    emit(
      state.copyWith(
        currentQuestion: _questions.first,
        answeredCorrectly: 0,
        isQuizComplete: false,
      ),
    );
  }
}

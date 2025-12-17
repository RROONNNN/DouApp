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

  Future<void> initialize(String lessonId) async {
    emit(state.copyWith(status: RequestStatus.requesting));
    try {
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

  void answerCorrectly(String questionId) {
    _questions.removeFirst();
    if (isQuizComplete()) {
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

  void answerIncorrectly(String questionId) {
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

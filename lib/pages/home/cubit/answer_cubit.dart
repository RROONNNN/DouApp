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

  Future<void> initialize(String lessonId) async {
    emit(
      state.copyWith(status: RequestStatus.requesting, currentQuestionIndex: 0),
    );
    try {
      final questions = await learningService.getQuestions(lessonId);
      // for test : filter all questions to only have ordering questions
      final orderingQuestions = questions
          .where(
            (question) => question.typeQuestion == TypeQuestion.multipleChoice,
          )
          .toList();
      emit(
        state.copyWith(
          status: RequestStatus.success,
          questions: orderingQuestions,
          totalQuestions: orderingQuestions.length,
          answeredCorrectly: {},
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

  void answerCorrectly(String questionId) {
    final newAnsweredCorrectly = Set<String>.from(state.answeredCorrectly)
      ..add(questionId);
    emit(state.copyWith(answeredCorrectly: newAnsweredCorrectly));

    // Move to next question after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      nextQuestion();
    });
  }

  void answerIncorrectly(String questionId) {
    // Add the question back to the end of the queue if not already there
    final currentQuestion = state.currentQuestion;
    if (currentQuestion != null && currentQuestion.id == questionId) {
      final updatedQuestions = List<Question>.from(state.questions);
      // Only add back if not at the end already
      if (state.currentQuestionIndex < updatedQuestions.length - 1) {
        updatedQuestions.add(currentQuestion);
      }

      emit(state.copyWith(questions: updatedQuestions));
    }

    // Move to next question after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    if (state.isQuizComplete) {
      // All questions answered correctly, show completion
      emit(state.copyWith(currentQuestionIndex: state.questions.length));
      return;
    }

    if (state.hasMoreQuestions) {
      emit(
        state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1),
      );
    }
  }

  void resetQuiz() {
    emit(state.copyWith(currentQuestionIndex: 0, answeredCorrectly: {}));
  }
}

import 'package:bloc/bloc.dart';
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
      emit(state.copyWith(status: RequestStatus.success, questions: questions));
    } catch (e) {
      emit(
        state.copyWith(
          status: RequestStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void nextQuestion() {
    if (state.hasMoreQuestions) {
      emit(
        state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1),
      );
    }
  }

  void resetQuiz() {
    emit(state.copyWith(currentQuestionIndex: 0));
  }
}

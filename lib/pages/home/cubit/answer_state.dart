part of 'answer_cubit.dart';

class AnswerState extends Equatable {
  final RequestStatus status;
  final List<Question> questions;
  final int currentQuestionIndex;
  final String? errorMessage;

  const AnswerState({
    this.status = RequestStatus.initial,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.errorMessage,
  });
  Question? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  bool get hasMoreQuestions => currentQuestionIndex < questions.length - 1;
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  @override
  List<Object> get props => [
    status,
    questions,
    currentQuestionIndex,
    errorMessage ?? '',
  ];

  AnswerState copyWith({
    RequestStatus? status,
    List<Question>? questions,
    int? currentQuestionIndex,
    String? errorMessage,
  }) {
    return AnswerState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

part of 'answer_cubit.dart';

class AnswerState extends Equatable {
  final RequestStatus status;
  final List<Question> questions;
  final int currentQuestionIndex;
  final String? errorMessage;
  final Set<String> answeredCorrectly;
  final int totalQuestions;

  const AnswerState({
    this.status = RequestStatus.initial,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.errorMessage,
    this.answeredCorrectly = const {},
    this.totalQuestions = 0,
  });

  Question? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  bool get hasMoreQuestions => currentQuestionIndex < questions.length - 1;
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isQuizComplete =>
      answeredCorrectly.length == totalQuestions && totalQuestions > 0;
  double get progress =>
      totalQuestions > 0 ? answeredCorrectly.length / totalQuestions : 0.0;

  @override
  List<Object> get props => [
    status,
    questions,
    currentQuestionIndex,
    errorMessage ?? '',
    answeredCorrectly,
    totalQuestions,
  ];

  AnswerState copyWith({
    RequestStatus? status,
    List<Question>? questions,
    int? currentQuestionIndex,
    String? errorMessage,
    Set<String>? answeredCorrectly,
    int? totalQuestions,
  }) {
    return AnswerState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      answeredCorrectly: answeredCorrectly ?? this.answeredCorrectly,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }
}

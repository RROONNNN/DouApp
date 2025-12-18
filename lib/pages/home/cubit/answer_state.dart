part of 'answer_cubit.dart';

class AnswerState extends Equatable {
  final RequestStatus status;
  final List<Question> questions;
  final Question? currentQuestion;
  final String? errorMessage;
  final int totalQuestions;
  final bool isQuizComplete;
  final int answeredCorrectly;
  final bool isHeartCountReached;

  const AnswerState({
    this.status = RequestStatus.initial,
    this.questions = const [],
    this.currentQuestion,
    this.errorMessage,
    this.totalQuestions = 0,
    this.isQuizComplete = false,
    this.answeredCorrectly = 0,
    this.isHeartCountReached = false,
  });

  @override
  List<Object> get props => [
    status,
    questions,
    currentQuestion ?? '',
    errorMessage ?? '',
    totalQuestions,
    isQuizComplete,
    answeredCorrectly,
    isHeartCountReached,
  ];

  AnswerState copyWith({
    RequestStatus? status,
    List<Question>? questions,
    Question? currentQuestion,
    String? errorMessage,
    int? totalQuestions,
    bool? isQuizComplete,
    int? answeredCorrectly,
    bool? isHeartCountReached,
  }) {
    return AnswerState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      errorMessage: errorMessage ?? this.errorMessage,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isQuizComplete: isQuizComplete ?? this.isQuizComplete,
      answeredCorrectly: answeredCorrectly ?? this.answeredCorrectly,
      isHeartCountReached: isHeartCountReached ?? this.isHeartCountReached,
    );
  }
}

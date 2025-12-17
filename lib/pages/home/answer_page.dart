import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/entities/question.dart';
import 'package:duo_app/pages/home/cubit/answer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnswerPage extends StatefulWidget {
  final String lessonId;
  const AnswerPage({super.key, required this.lessonId});

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  late final AnswerCubit _answerCubit;

  @override
  void initState() {
    super.initState();
    _answerCubit = getIt<AnswerCubit>()..initialize(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _answerCubit,
      child: BlocBuilder<AnswerCubit, AnswerState>(
        builder: (context, state) {
          if (state.status == RequestStatus.requesting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == RequestStatus.failed) {
            return Scaffold(
              body: Center(child: Text('Error: ${state.errorMessage}')),
            );
          }

          if (state.status == RequestStatus.initial) {
            return const Scaffold(body: SizedBox());
          }

          // Success - route to appropriate question type
          final question = state.currentQuestion;

          if (question == null) {
            // Quiz completed
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Quiz Completed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You answered ${state.questions.length} questions',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (question.typeQuestion == TypeQuestion.ordering) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: OrderingPage(
                  question: question,
                  questionNumber: state.currentQuestionIndex + 1,
                  totalQuestions: state.questions.length,
                  onComplete: () => context.read<AnswerCubit>().nextQuestion(),
                ),
              ),
            );
          } else if (question.typeQuestion == TypeQuestion.multipleChoice) {
            return MultipleChoicePage(
              question: question,
              questionNumber: state.currentQuestionIndex + 1,
              totalQuestions: state.questions.length,
              onComplete: () => context.read<AnswerCubit>().nextQuestion(),
            );
          } else if (question.typeQuestion == TypeQuestion.matching) {
            return MatchingPage(
              question: question,
              questionNumber: state.currentQuestionIndex + 1,
              totalQuestions: state.questions.length,
              onComplete: () => context.read<AnswerCubit>().nextQuestion(),
            );
          }

          return const Scaffold(
            body: Center(child: Text('Question type not supported')),
          );
        },
      ),
    );
  }
}

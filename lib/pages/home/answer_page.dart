import 'package:cached_network_image/cached_network_image.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/resources/app_design_system.dart';
import 'package:duo_app/common/utils/widgets/loading_page.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/entities/question.dart';
import 'package:duo_app/entities/user.dart';
import 'package:duo_app/pages/bloc/app_bloc.dart';
import 'package:duo_app/pages/bloc/app_state.dart';
import 'package:duo_app/pages/home/cubit/answer_cubit.dart';
import 'package:duo_app/pages/home/elements/gap_filling_page.dart';
import 'package:duo_app/pages/home/elements/matching_page.dart';
import 'package:duo_app/pages/home/elements/ordering_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';

class AnswerPage extends StatefulWidget {
  final String? lessonId;
  final String? courseId;
  final String? unitId;
  final int? experiencePoint;
  final bool isMistake;
  final List<Question> questions;

  const AnswerPage({
    super.key,
    this.lessonId,
    this.courseId,
    this.unitId,
    this.experiencePoint,
    this.questions = const [],
    this.isMistake = false,
  }) : assert(
         isMistake ||
             (lessonId != null &&
                 courseId != null &&
                 unitId != null &&
                 experiencePoint != null),
         'When isMistake is false, lessonId, courseId, unitId, and experiencePoint must not be null.',
       );

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  late final AnswerCubit _answerCubit;
  late final AudioPlayer _audioPlayer;
  late final _appBloc;

  @override
  void initState() {
    super.initState();
    _appBloc = getIt<AppBloc>();
    _answerCubit = getIt<AnswerCubit>()
      ..initialize(
        widget.lessonId ?? '',
        widget.courseId ?? '',
        widget.unitId ?? '',
        widget.experiencePoint ?? 0,
        _appBloc.state.user?.heartCount ?? 0,
        widget.isMistake,
        widget.questions,
      );

    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _appBloc.loadProfile();
    super.dispose();
  }

  Future<void> _playSound(bool isCorrect) async {
    try {
      await _audioPlayer.stop();
      if (isCorrect) {
        await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } else {
        await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _handleCorrectAnswer(String questionId) {
    _playSound(true);
    _answerCubit.answerCorrectly(questionId);
  }

  void _handleWrongAnswer(String questionId, {bool isShouldDelay = false}) {
    _playSound(false);
    _answerCubit.answerIncorrectly(questionId, isShouldDelay: isShouldDelay);
  }

  void _handleNextQuestionOnIncorrectly() {
    _answerCubit.nextQuestionOnIncorrectly();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _answerCubit,
      child: BlocBuilder<AnswerCubit, AnswerState>(
        builder: (context, state) {
          if (state.isHeartCountReached) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 64),
                    const SizedBox(height: 24),
                    const Text(
                      'No hearts left!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You\'ve run out of hearts.\nPlease wait until tomorrow to try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          if (state.status == RequestStatus.requesting) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppDesignSystem.surfaceLight,
                      AppDesignSystem.surfaceWhite,
                    ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1976D2),
                    ),
                  ),
                ),
              ),
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

          if (state.isQuizComplete) {
            // Quiz completed - show completion screen
            return _buildCompletionScreen(state);
          }
          // Render the appropriate question type with progress bar
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildProgressBar(state),
                  Expanded(child: _buildQuestionWidget(question!, state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(AnswerState state) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppDesignSystem.shadowLow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppDesignSystem.textSecondary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                '${state.answeredCorrectly} / ${state.totalQuestions}',
                style: AppDesignSystem.titleMedium.copyWith(
                  color: AppDesignSystem.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48), // Balance the close button
            ],
          ),
          const SizedBox(height: AppDesignSystem.spacing8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
            child: LinearProgressIndicator(
              value: state.answeredCorrectly / state.totalQuestions,
              minHeight: 8,
              backgroundColor: AppDesignSystem.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(Question question, AnswerState state) {
    // final isAnswered = state.questions.any((q) => q.id == question.id);

    if (question.typeQuestion == TypeQuestion.multipleChoice) {
      return MultipleChoicePage(
        key: Key(question.id),
        question: question,
        onCorrect: () => _handleCorrectAnswer(question.id),
        onWrong: () => _handleWrongAnswer(question.id),
      );
    } else if (question.typeQuestion == TypeQuestion.ordering) {
      return OrderingPage(
        key: Key(question.id),
        question: question,
        onComplete: () => _handleCorrectAnswer(question.id),
        onWrong: () => _handleWrongAnswer(question.id),
      );
    } else if (question.typeQuestion == TypeQuestion.matching) {
      return MatchingPage(
        key: Key(question.id),
        question: question,
        onComplete: () => _handleCorrectAnswer(question.id),
      );
    } else if (question.typeQuestion == TypeQuestion.gap) {
      return GapFillingPage(
        key: Key(question.id),
        question: question,
        onComplete: () => _handleCorrectAnswer(question.id),
        onWrong: () => _handleWrongAnswer(question.id, isShouldDelay: true),
        onNext: () => _handleNextQuestionOnIncorrectly(),
      );
    }
    return const Center(child: Text('Question type not supported'));
  }

  Widget _buildCompletionScreen(AnswerState state) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppDesignSystem.surfaceLight,
              AppDesignSystem.surfaceWhite,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDesignSystem.spacing32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success animation with trophy
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(
                            AppDesignSystem.spacing40,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1976D2).withOpacity(0.3),
                                blurRadius: 24,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDesignSystem.spacing40),

                  // Congratulations text
                  Text(
                    'Congratulations!',
                    style: AppDesignSystem.displayMedium.copyWith(
                      color: const Color(0xFF1976D2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDesignSystem.spacing12),
                  Text(
                    'Quiz Completed',
                    style: AppDesignSystem.titleLarge.copyWith(
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppDesignSystem.spacing32),

                  // Stats card
                  Container(
                    padding: const EdgeInsets.all(AppDesignSystem.spacing24),
                    decoration: AppDesignSystem.cardDecoration(
                      shadows: AppDesignSystem.shadowMedium,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              Icons.check_circle_rounded,
                              '${state.totalQuestions}',
                              'Questions',
                              const Color(0xFF1976D2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDesignSystem.spacing48),

                  // Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDesignSystem.radiusMedium,
                            ),
                            boxShadow: AppDesignSystem.shadowMedium,
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDesignSystem.radiusMedium,
                                ),
                              ),
                            ),
                            child: Text(
                              'Continue Learning',
                              style: AppDesignSystem.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDesignSystem.spacing16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => _answerCubit.resetQuiz(
                            state.currentQuestion?.id ?? '',
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF1976D2),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDesignSystem.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Retry Quiz',
                            style: AppDesignSystem.titleLarge.copyWith(
                              color: const Color(0xFF1976D2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppDesignSystem.spacing8),
        Text(
          value,
          style: AppDesignSystem.headlineLarge.copyWith(
            color: AppDesignSystem.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }
}

class MultipleChoicePage extends StatelessWidget {
  const MultipleChoicePage({
    super.key,
    required this.question,
    required this.onCorrect,
    required this.onWrong,
  });
  final Question question;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppDesignSystem.surfaceLight, AppDesignSystem.surfaceWhite],
        ),
      ),
      child: Column(
        children: [
          // Image Section with modern styling
          Container(
            margin: const EdgeInsets.all(AppDesignSystem.spacing16),
            decoration: AppDesignSystem.cardDecoration(
              shadows: AppDesignSystem.shadowHigh,
              borderRadius: AppDesignSystem.radiusLarge,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
              child: CachedNetworkImage(
                height: 240,
                width: double.infinity,
                fit: BoxFit.contain,
                imageUrl: question.mediaUrl ?? '',
                placeholder: (context, url) => Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppDesignSystem.surfaceGrey,
                        AppDesignSystem.surfaceLight,
                      ],
                    ),
                  ),
                  child: const LoadingPage(),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppDesignSystem.surfaceGrey,
                        AppDesignSystem.surfaceLight,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.image_not_supported_rounded,
                    size: 64,
                    color: AppDesignSystem.textTertiary,
                  ),
                ),
              ),
            ),
          ),

          // Question prompt
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignSystem.spacing24,
              vertical: AppDesignSystem.spacing16,
            ),
            child: Text(
              'Choose the correct answer',
              style: AppDesignSystem.titleLarge.copyWith(
                color: AppDesignSystem.textSecondary,
              ),
            ),
          ),

          // Answer Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDesignSystem.spacing16),
              child: GridView.builder(
                itemCount: question.answers?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: AppDesignSystem.spacing16,
                  mainAxisSpacing: AppDesignSystem.spacing16,
                ),
                itemBuilder: (context, index) {
                  return _AnimatedAnswerButton(
                    answer: question.answers?[index] ?? '',
                    onPressed: () {
                      if (question.answers?[index] == question.correctAnswer) {
                        onCorrect();
                      } else {
                        onWrong();
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedAnswerButton extends StatefulWidget {
  final String answer;
  final VoidCallback onPressed;

  const _AnimatedAnswerButton({required this.answer, required this.onPressed});

  @override
  State<_AnimatedAnswerButton> createState() => _AnimatedAnswerButtonState();
}

class _AnimatedAnswerButtonState extends State<_AnimatedAnswerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDesignSystem.animationFast,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              Future.delayed(AppDesignSystem.animationFast, widget.onPressed);
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 - (_controller.value * 0.05),
                  child: Container(
                    decoration: AppDesignSystem.cardDecoration(
                      gradient: _isPressed
                          ? const LinearGradient(
                              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                            )
                          : null,
                      color: _isPressed ? null : AppDesignSystem.surfaceWhite,
                      shadows: _isPressed
                          ? AppDesignSystem.shadowLow
                          : AppDesignSystem.shadowMedium,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppDesignSystem.spacing16,
                        ),
                        child: Text(
                          widget.answer,
                          style: AppDesignSystem.titleMedium.copyWith(
                            color: _isPressed
                                ? Colors.white
                                : AppDesignSystem.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

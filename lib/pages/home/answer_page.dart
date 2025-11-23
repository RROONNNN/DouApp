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
          }

          return const Scaffold(
            body: Center(child: Text('Question type not supported')),
          );
        },
      ),
    );
  }
}

// ============= ORDERING PAGE =============
class OrderingPage extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final VoidCallback onComplete;

  const OrderingPage({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onComplete,
  });

  @override
  State<OrderingPage> createState() => _OrderingPageState();
}

class _OrderingPageState extends State<OrderingPage> {
  late final List<String> wordBank;
  final List<int> selectedIndexes = [];

  final Map<int, Offset> wordPositions = {};

  OverlayEntry? flyingEntry;

  final GlobalKey _selectedWordsWrapKey = GlobalKey();
  int? _pendingWordIndex;

  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize wordBank from question fragmentText
    wordBank = widget.question.fragmentText ?? [];
  }

  @override
  void dispose() {
    flyingEntry?.remove();
    super.dispose();
  }

  Offset getNextTargetPosition(BuildContext context, int wordIndex) {
    final selectedIndex = selectedIndexes.indexOf(wordIndex);
    if (selectedIndex == -1) {
      return const Offset(16.0, 80.0);
    }

    final itemKey = _itemKeys[selectedIndex];

    if (itemKey?.currentContext != null) {
      final itemBox = itemKey!.currentContext!.findRenderObject() as RenderBox?;

      if (itemBox != null) {
        final itemPosition = itemBox.localToGlobal(Offset.zero);
        final itemSize = itemBox.size;

        final centerPosition = Offset(
          itemPosition.dx + itemSize.width / 2,
          itemPosition.dy + itemSize.height / 2,
        );

        return centerPosition;
      }
    }

    final wrapRenderBox =
        _selectedWordsWrapKey.currentContext?.findRenderObject() as RenderBox?;
    if (wrapRenderBox != null) {
      final wrapPosition = wrapRenderBox.localToGlobal(Offset.zero);
      const estimatedWidth = 70.0;
      const estimatedHeight = 40.0;
      return Offset(
        wrapPosition.dx + estimatedWidth / 2,
        wrapPosition.dy + estimatedHeight / 2,
      );
    }

    return const Offset(16.0, 80.0);
  }

  void triggerFlyAnimation(BuildContext context, int wordIndex) async {
    final startPos = wordPositions[wordIndex];
    if (startPos == null) return;

    if (selectedIndexes.contains(wordIndex)) return;

    setState(() {
      _pendingWordIndex = wordIndex;
      selectedIndexes.add(wordIndex);
    });

    await SchedulerBinding.instance.endOfFrame;

    final endPos = getNextTargetPosition(context, wordIndex);

    flyingEntry?.remove();

    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) {
        return AnimatedFlyWord(
          word: wordBank[wordIndex],
          start: startPos,
          end: endPos,
        );
      },
    );

    flyingEntry = entry;
    overlay.insert(entry);

    await Future.delayed(const Duration(milliseconds: 350));

    entry.remove();
    flyingEntry = null;

    setState(() {
      _pendingWordIndex = null;
    });
  }

  Widget buildWordTile(int index, {bool isForTarget = false}) {
    final isGhost = !isForTarget ? selectedIndexes.contains(index) : false;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: isGhost ? Colors.grey.shade300 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: isGhost
            ? []
            : [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Text(wordBank[index], style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: widget.questionNumber / widget.totalQuestions,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(width: 16),
              Text('${widget.questionNumber}/${widget.totalQuestions}'),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Tap the words in the correct order',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 30),
        Wrap(
          key: _selectedWordsWrapKey,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(selectedIndexes.length, (index) {
            final wordIndex = selectedIndexes[index];
            if (!_itemKeys.containsKey(index)) {
              _itemKeys[index] = GlobalKey();
            }
            final itemKey = _itemKeys[index]!;
            final isPending = wordIndex == _pendingWordIndex;
            return Opacity(
              key: itemKey,
              opacity: isPending ? 0.0 : 1.0,
              child: GestureDetector(
                onTap: () {
                  debugPrint('onTap: ${wordBank[wordIndex]}');
                  _itemKeys.remove(index);
                  setState(() {
                    selectedIndexes.removeAt(index);
                  });
                },
                child: buildWordTile(wordIndex, isForTarget: true),
              ),
            );
          }),
        ),
        const SizedBox(height: 60),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(wordBank.length, (index) {
            return GestureDetector(
              onTapDown: (details) {
                wordPositions[index] = details.globalPosition;
              },
              onTap: () {
                triggerFlyAnimation(context, index);
              },
              child: buildWordTile(index),
            );
          }),
        ),
        const Spacer(),
        // Check button
        if (selectedIndexes.length == wordBank.length)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CHECK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============= MULTIPLE CHOICE PAGE =============
class MultipleChoicePage extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final VoidCallback onComplete;

  const MultipleChoicePage({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onComplete,
  });

  @override
  State<MultipleChoicePage> createState() => _MultipleChoicePageState();
}

class _MultipleChoicePageState extends State<MultipleChoicePage> {
  String? selectedAnswer;
  bool? isCorrect;
  bool hasChecked = false;

  void checkAnswer() {
    setState(() {
      hasChecked = true;
      isCorrect = selectedAnswer == widget.question.correctAnswer;
    });
  }

  Color getButtonColor(String answer) {
    if (!hasChecked) {
      return selectedAnswer == answer ? Colors.blue.shade100 : Colors.white;
    }

    if (answer == widget.question.correctAnswer) {
      return Colors.green.shade100;
    }

    if (selectedAnswer == answer && !isCorrect!) {
      return Colors.red.shade100;
    }

    return Colors.white;
  }

  Color getBorderColor(String answer) {
    if (!hasChecked) {
      return selectedAnswer == answer ? Colors.blue : Colors.grey.shade300;
    }

    if (answer == widget.question.correctAnswer) {
      return Colors.green;
    }

    if (selectedAnswer == answer && !isCorrect!) {
      return Colors.red;
    }

    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            LinearProgressIndicator(
              value: widget.questionNumber / widget.totalQuestions,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.questionNumber}/${widget.totalQuestions}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What is this?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Image
                    if (widget.question.mediaUrl != null &&
                        widget.question.mediaUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.question.mediaUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Answer options
                    ...widget.question.answers!.map((answer) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: hasChecked
                              ? null
                              : () {
                                  setState(() {
                                    selectedAnswer = answer;
                                  });
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: getButtonColor(answer),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: getBorderColor(answer),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    answer,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (hasChecked &&
                                    answer == widget.question.correctAnswer)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                if (hasChecked &&
                                    selectedAnswer == answer &&
                                    !isCorrect!)
                                  const Icon(Icons.cancel, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedAnswer == null
                        ? null
                        : hasChecked
                        ? widget.onComplete
                        : checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasChecked
                          ? (isCorrect! ? Colors.green : Colors.red)
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Text(
                      hasChecked ? 'CONTINUE' : 'CHECK',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= ANIMATED FLY WORD =============
class AnimatedFlyWord extends StatefulWidget {
  final String word;
  final Offset start;
  final Offset end;

  const AnimatedFlyWord({
    super.key,
    required this.word,
    required this.start,
    required this.end,
  });

  @override
  State<AnimatedFlyWord> createState() => _AnimatedFlyWordState();
}

class _AnimatedFlyWordState extends State<AnimatedFlyWord>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animation = Tween<Offset>(
      begin: widget.start,
      end: widget.end,
    ).animate(CurvedAnimation(curve: Curves.easeOut, parent: controller));

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Positioned(
          left: animation.value.dx,
          top: animation.value.dy,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.yellow.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                widget.word,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

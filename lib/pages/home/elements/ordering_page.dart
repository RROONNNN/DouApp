import 'package:duo_app/common/resources/app_design_system.dart';
import 'package:duo_app/entities/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class OrderingPage extends StatefulWidget {
  final Question question;

  final VoidCallback onComplete;

  final VoidCallback onWrong;

  const OrderingPage({
    super.key,
    required this.question,
    required this.onComplete,
    required this.onWrong,
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

  // State for answer checking
  bool _hasSubmitted = false;
  bool _isCorrect = false;

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

  void _checkAnswer() {
    // Build the user's answer from selected words
    final userAnswer = selectedIndexes
        .map((index) => wordBank[index])
        .join(' ');

    // Compare with correct answer
    final correctAnswer = widget.question.correctAnswer ?? '';

    setState(() {
      _hasSubmitted = true;
      _isCorrect =
          userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    });

    // Call appropriate callback after a short delay
    if (_isCorrect) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          widget.onComplete();
        }
      });
    } else {
      widget.onWrong();
    }
  }

  Widget buildWordTile(int index, {bool isForTarget = false}) {
    final isGhost = !isForTarget ? selectedIndexes.contains(index) : false;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDesignSystem.spacing12,
        horizontal: AppDesignSystem.spacing16,
      ),
      decoration: AppDesignSystem.cardDecoration(
        color: isGhost
            ? AppDesignSystem.surfaceGrey.withOpacity(0.5)
            : AppDesignSystem.surfaceWhite,
        gradient: isForTarget && !isGhost ? AppDesignSystem.blueGradient : null,
        borderRadius: AppDesignSystem.radiusMedium,
        shadows: isGhost ? [] : AppDesignSystem.shadowMedium,
        border: isGhost
            ? Border.all(
                color: AppDesignSystem.surfaceGrey,
                width: 1.5,
                style: BorderStyle.solid,
              )
            : null,
      ),
      child: Text(
        wordBank[index],
        style: AppDesignSystem.titleMedium.copyWith(
          color: isForTarget && !isGhost
              ? Colors.white
              : isGhost
              ? AppDesignSystem.textTertiary
              : AppDesignSystem.textPrimary,
          fontWeight: isForTarget ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

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
          const SizedBox(height: AppDesignSystem.spacing24),
          // Title with icon
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignSystem.spacing24,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDesignSystem.spacing12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMedium,
                    ),
                    boxShadow: AppDesignSystem.shadowMedium,
                  ),
                  child: const Icon(
                    Icons.reorder_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDesignSystem.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order the words',
                        style: AppDesignSystem.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap words in the correct order',
                        style: AppDesignSystem.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDesignSystem.spacing32),

          // Selected words area with decorative container
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDesignSystem.spacing20,
            ),
            padding: const EdgeInsets.all(AppDesignSystem.spacing16),
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              color: AppDesignSystem.surfaceWhite,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
              border: Border.all(
                color: const Color(0xFF1976D2).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: selectedIndexes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 40,
                          color: AppDesignSystem.textTertiary.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppDesignSystem.spacing8),
                        Text(
                          'Tap words below to build your answer',
                          style: AppDesignSystem.bodyMedium.copyWith(
                            color: AppDesignSystem.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Wrap(
                    key: _selectedWordsWrapKey,
                    spacing: AppDesignSystem.spacing8,
                    runSpacing: AppDesignSystem.spacing8,
                    children: List.generate(selectedIndexes.length, (index) {
                      final wordIndex = selectedIndexes[index];
                      if (!_itemKeys.containsKey(index)) {
                        _itemKeys[index] = GlobalKey();
                      }
                      final itemKey = _itemKeys[index]!;
                      final isPending = wordIndex == _pendingWordIndex;
                      return TweenAnimationBuilder<double>(
                        key: itemKey,
                        tween: Tween(begin: 0.0, end: isPending ? 0.0 : 1.0),
                        duration: AppDesignSystem.animationFast,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: 0.8 + (value * 0.2),
                              child: GestureDetector(
                                onTap: () {
                                  if (!_hasSubmitted) {
                                    _itemKeys.remove(index);
                                    setState(() {
                                      selectedIndexes.removeAt(index);
                                    });
                                  }
                                },
                                child: buildWordTile(
                                  wordIndex,
                                  isForTarget: true,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
          ),

          const SizedBox(height: AppDesignSystem.spacing40),

          // Word bank
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignSystem.spacing20,
            ),
            child: Wrap(
              spacing: AppDesignSystem.spacing12,
              runSpacing: AppDesignSystem.spacing12,
              alignment: WrapAlignment.center,
              children: List.generate(wordBank.length, (index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: GestureDetector(
                        onTapDown: (details) {
                          if (!_hasSubmitted) {
                            wordPositions[index] = details.globalPosition;
                          }
                        },
                        onTap: () {
                          if (!_hasSubmitted) {
                            triggerFlyAnimation(context, index);
                          }
                        },
                        child: buildWordTile(index),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          // Result feedback
          if (_hasSubmitted)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignSystem.spacing20,
                vertical: AppDesignSystem.spacing16,
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDesignSystem.spacing20,
                        vertical: AppDesignSystem.spacing16,
                      ),
                      decoration: BoxDecoration(
                        color: _isCorrect
                            ? AppDesignSystem.successGreen.withOpacity(0.1)
                            : AppDesignSystem.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDesignSystem.radiusMedium,
                        ),
                        border: Border.all(
                          color: _isCorrect
                              ? AppDesignSystem.successGreen
                              : AppDesignSystem.errorRed,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: _isCorrect
                                ? AppDesignSystem.successGreen
                                : AppDesignSystem.errorRed,
                            size: 28,
                          ),
                          const SizedBox(width: AppDesignSystem.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isCorrect ? 'Perfect!' : 'Incorrect',
                                  style: AppDesignSystem.titleMedium.copyWith(
                                    color: _isCorrect
                                        ? AppDesignSystem.successGreen
                                        : AppDesignSystem.errorRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!_isCorrect) ...[
                                  const SizedBox(
                                    height: AppDesignSystem.spacing4,
                                  ),
                                  Text(
                                    'Correct answer: ${widget.question.correctAnswer}',
                                    style: AppDesignSystem.bodyMedium.copyWith(
                                      color: AppDesignSystem.errorRed,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const Spacer(),

          // Check button
          if (selectedIndexes.length == wordBank.length)
            Padding(
              padding: const EdgeInsets.all(AppDesignSystem.spacing20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: SizedBox(
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
                          boxShadow: AppDesignSystem.shadowHigh,
                        ),
                        child: ElevatedButton(
                          onPressed: _hasSubmitted ? null : _checkAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDesignSystem.radiusMedium,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: AppDesignSystem.spacing12),
                              Text(
                                'CHECK',
                                style: AppDesignSystem.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

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
              padding: const EdgeInsets.symmetric(
                vertical: AppDesignSystem.spacing12,
                horizontal: AppDesignSystem.spacing16,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFEB3B), Color(0xFFFFC107)],
                ),
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusMedium,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.word,
                style: AppDesignSystem.titleMedium.copyWith(
                  color: AppDesignSystem.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
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

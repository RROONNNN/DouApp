import 'package:duo_app/common/resources/app_design_system.dart';
import 'package:duo_app/entities/question.dart';
import 'package:flutter/material.dart';

class MatchingPage extends StatefulWidget {
  final Question question;
  final VoidCallback onComplete;
  const MatchingPage({
    super.key,
    required this.question,
    required this.onComplete,
  });

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage>
    with TickerProviderStateMixin {
  // Track selected items
  String? _selectedLeftId;
  String? _selectedRightId;

  // Track matched pairs
  final Set<String> _matchedPairIds = {};

  // Track item states (for colors)
  final Map<String, _ItemState> _itemStates = {};

  // Animation controllers
  final Map<String, AnimationController> _successControllers = {};
  final Map<String, AnimationController> _shakeControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final leftItems = widget.question.leftText ?? [];
    final rightItems = widget.question.rightText ?? [];

    for (var item in [...leftItems, ...rightItems]) {
      // Success scale animation
      _successControllers[item.pairId] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );

      // Shake animation
      _shakeControllers[item.pairId] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _successControllers.values) {
      controller.dispose();
    }
    for (var controller in _shakeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleLeftTap(MatchingItem item) {
    if (_matchedPairIds.contains(item.pairId)) return;

    setState(() {
      if (_selectedLeftId == item.pairId) {
        // Deselect if tapping the same item
        _selectedLeftId = null;
      } else {
        _selectedLeftId = item.pairId;
        // Check if we have a right item selected for matching
        if (_selectedRightId != null) {
          _checkMatch();
        }
      }
    });
  }

  void _handleRightTap(MatchingItem item) {
    if (_matchedPairIds.contains(item.pairId)) return;

    setState(() {
      if (_selectedRightId == item.pairId) {
        // Deselect if tapping the same item
        _selectedRightId = null;
      } else {
        _selectedRightId = item.pairId;
        // Check if we have a left item selected for matching
        if (_selectedLeftId != null) {
          _checkMatch();
        }
      }
    });
  }

  Future<void> _checkMatch() async {
    if (_selectedLeftId == null || _selectedRightId == null) return;

    final leftId = _selectedLeftId!;
    final rightId = _selectedRightId!;

    if (leftId == rightId) {
      // SUCCESS - Correct match
      setState(() {
        _itemStates[leftId] = _ItemState.success;
        _itemStates[rightId] = _ItemState.success;
      });
      setState(() {
        _matchedPairIds.add(leftId);
        _selectedLeftId = null;
        _selectedRightId = null;
      });
      // Play success animation
      await Future.wait([
        _successControllers[leftId]!.forward(),
        _successControllers[rightId]!.forward(),
      ]);
    } else {
      // FAILURE - Wrong match
      setState(() {
        _itemStates[leftId] = _ItemState.error;
        _itemStates[rightId] = _ItemState.error;
      });

      // Play shake animation
      await Future.wait([
        _shakeControllers[leftId]!.forward(from: 0),
        _shakeControllers[rightId]!.forward(from: 0),
      ]);

      // Reset after animation
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _itemStates.remove(leftId);
        _itemStates.remove(rightId);
        _selectedLeftId = null;
        _selectedRightId = null;
      });
    }
  }

  bool get _isCompleted {
    final totalPairs = widget.question.leftText?.length ?? 0;
    return _matchedPairIds.length == totalPairs;
  }

  @override
  Widget build(BuildContext context) {
    final leftItems = widget.question.leftText ?? [];
    final rightItems = widget.question.rightText ?? [];

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
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.spacing16,
                  vertical: AppDesignSystem.spacing12,
                ),
                decoration: BoxDecoration(
                  color: AppDesignSystem.surfaceWhite,
                  boxShadow: AppDesignSystem.shadowLow,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(AppDesignSystem.spacing8),
                        decoration: BoxDecoration(
                          color: AppDesignSystem.surfaceLight,
                          borderRadius: BorderRadius.circular(
                            AppDesignSystem.radiusSmall,
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppDesignSystem.textSecondary,
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: AppDesignSystem.spacing8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Match the pairs',
                            style: AppDesignSystem.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_matchedPairIds.length}/${leftItems.length} matched',
                            style: AppDesignSystem.bodyMedium.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress indicator
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.spacing16,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDesignSystem.radiusFull,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.0,
                      end: _matchedPairIds.length / leftItems.length,
                    ),
                    duration: AppDesignSystem.animationNormal,
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppDesignSystem.surfaceGrey,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppDesignSystem.primaryGreen,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppDesignSystem.spacing24),

              // Matching area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.spacing16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column
                      Expanded(
                        child: _buildColumn(
                          items: leftItems,
                          isLeft: true,
                          selectedId: _selectedLeftId,
                          onTap: _handleLeftTap,
                        ),
                      ),
                      const SizedBox(width: AppDesignSystem.spacing16),

                      // Divider line
                      Container(
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppDesignSystem.surfaceGrey,
                              AppDesignSystem.primaryGreenLight.withOpacity(
                                0.3,
                              ),
                              AppDesignSystem.surfaceGrey,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDesignSystem.radiusFull,
                          ),
                        ),
                      ),

                      const SizedBox(width: AppDesignSystem.spacing16),

                      // Right column
                      Expanded(
                        child: _buildColumn(
                          items: rightItems,
                          isLeft: false,
                          selectedId: _selectedRightId,
                          onTap: _handleRightTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Continue button (shown when completed)
              if (_isCompleted)
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
                              gradient: AppDesignSystem.successGradient,
                              borderRadius: BorderRadius.circular(
                                AppDesignSystem.radiusMedium,
                              ),
                              boxShadow: AppDesignSystem.shadowHigh,
                            ),
                            child: ElevatedButton(
                              onPressed: widget.onComplete,
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
                                  Text(
                                    'Continue',
                                    style: AppDesignSystem.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppDesignSystem.spacing8,
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildColumn({
    required List<MatchingItem> items,
    required bool isLeft,
    required String? selectedId,
    required Function(MatchingItem) onTap,
  }) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isMatched = _matchedPairIds.contains(item.pairId);
        final isSelected = selectedId == item.pairId;
        final state = _itemStates[item.pairId];

        return _buildMatchingItem(
          item: item,
          isMatched: isMatched,
          isSelected: isSelected,
          state: state,
          onTap: () => onTap(item),
        );
      },
    );
  }

  Widget _buildMatchingItem({
    required MatchingItem item,
    required bool isMatched,
    required bool isSelected,
    required _ItemState? state,
    required VoidCallback onTap,
  }) {
    Gradient? gradient;
    Color? backgroundColor;
    Color borderColor;
    Color textColor;
    List<BoxShadow>? shadows;

    if (state == _ItemState.success || isMatched) {
      gradient = AppDesignSystem.successGradient;
      borderColor = AppDesignSystem.successGreen;
      textColor = Colors.white;
      shadows = AppDesignSystem.shadowMedium;
    } else if (state == _ItemState.error) {
      backgroundColor = AppDesignSystem.errorRed.withOpacity(0.1);
      borderColor = AppDesignSystem.errorRed;
      textColor = AppDesignSystem.errorRed;
      shadows = AppDesignSystem.shadowLow;
    } else if (isSelected) {
      gradient = AppDesignSystem.blueGradient;
      borderColor = AppDesignSystem.secondaryBlue;
      textColor = Colors.white;
      shadows = AppDesignSystem.shadowMedium;
    } else {
      backgroundColor = AppDesignSystem.surfaceWhite;
      borderColor = AppDesignSystem.surfaceGrey;
      textColor = AppDesignSystem.textPrimary;
      shadows = AppDesignSystem.shadowLow;
    }

    Widget child = GestureDetector(
      onTap: isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: AppDesignSystem.animationFast,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spacing16,
          vertical: AppDesignSystem.spacing16,
        ),
        decoration: AppDesignSystem.cardDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: AppDesignSystem.radiusMedium,
          shadows: shadows,
          border: Border.all(
            color: borderColor,
            width: isSelected || isMatched ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isMatched) ...[
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppDesignSystem.spacing8),
              ],
              Flexible(
                child: Text(
                  item.value,
                  style: AppDesignSystem.titleMedium.copyWith(
                    fontWeight: isSelected || isMatched
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Apply success scale animation
    if (isMatched && _successControllers[item.pairId] != null) {
      child = ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.08).animate(
          CurvedAnimation(
            parent: _successControllers[item.pairId]!,
            curve: Curves.elasticOut,
          ),
        ),
        child: child,
      );
    }

    // Apply shake animation for errors
    if (state == _ItemState.error && _shakeControllers[item.pairId] != null) {
      child = AnimatedBuilder(
        animation: _shakeControllers[item.pairId]!,
        builder: (context, child) {
          final value = _shakeControllers[item.pairId]!.value;
          final offset = 8 * (1 - value) * (value < 0.5 ? 1 : -1);
          return Transform.translate(
            offset: Offset(offset, 0),
            child: Transform.rotate(angle: offset * 0.02, child: child),
          );
        },
        child: child,
      );
    }

    return child;
  }
}

enum _ItemState { success, error }

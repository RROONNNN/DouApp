import 'package:audioplayers/audioplayers.dart';
import 'package:duo_app/common/resources/app_design_system.dart';
import 'package:duo_app/entities/question.dart';
import 'package:flutter/material.dart';

class GapFillingPage extends StatefulWidget {
  final Question question;
  final VoidCallback onComplete;

  const GapFillingPage({
    super.key,
    required this.question,
    required this.onComplete,
  });

  @override
  State<GapFillingPage> createState() => _GapFillingPageState();
}

class _GapFillingPageState extends State<GapFillingPage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _feedbackController;

  bool _isPlaying = false;
  bool _hasSubmitted = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupAudioPlayer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final url = widget.question.mediaUrl;
        if (url != null && url.isNotEmpty) {
          await _audioPlayer.play(UrlSource(url));
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: AppDesignSystem.errorRed,
          ),
        );
      }
    }
  }

  void _checkAnswer() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _hasSubmitted = true;
      _isCorrect =
          _textController.text.trim().toLowerCase() ==
          widget.question.correctAnswer?.toLowerCase();
    });

    _feedbackController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
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
              _buildAppBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDesignSystem.spacing40),
                      _buildAudioPlayer(),
                      const SizedBox(height: AppDesignSystem.spacing48),
                      _buildInputSection(),
                      if (_hasSubmitted) ...[
                        const SizedBox(height: AppDesignSystem.spacing24),
                        _buildResultIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
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
                Text('Listen and Spell', style: AppDesignSystem.titleLarge),
                const SizedBox(height: 2),
                Text(
                  'Type what you hear',
                  style: AppDesignSystem.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: _playAudio,
            child: Container(
              padding: const EdgeInsets.all(AppDesignSystem.spacing32),
              decoration: BoxDecoration(
                gradient: _isPlaying
                    ? AppDesignSystem.blueGradient
                    : AppDesignSystem.greenGradient,
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusXLarge,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isPlaying
                                ? AppDesignSystem.secondaryBlue
                                : AppDesignSystem.primaryGreen)
                            .withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Play button with animation
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isPlaying
                            ? 1.0 + (_pulseController.value * 0.1)
                            : 1.0,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDesignSystem.spacing20),
                  // Sound waves animation
                  if (_isPlaying)
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final delay = index * 0.1;
                            final value = (_waveController.value + delay) % 1.0;
                            final height = 4.0 + (value * 20.0);
                            return Container(
                              width: 4,
                              height: height,
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppDesignSystem.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppDesignSystem.radiusFull,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  if (!_isPlaying)
                    Text(
                      'Tap to play',
                      style: AppDesignSystem.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.spacing24),
      decoration: AppDesignSystem.cardDecoration(
        shadows: AppDesignSystem.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.spacing8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDesignSystem.radiusSmall,
                  ),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppDesignSystem.secondaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDesignSystem.spacing12),
              Text('Type your answer', style: AppDesignSystem.titleMedium),
            ],
          ),
          const SizedBox(height: AppDesignSystem.spacing20),
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            enabled: !_hasSubmitted || !_isCorrect,
            autofocus: true,
            textAlign: TextAlign.center,
            style: AppDesignSystem.headlineMedium.copyWith(letterSpacing: 2.0),
            decoration: InputDecoration(
              hintText: '...',
              hintStyle: AppDesignSystem.headlineMedium.copyWith(
                color: AppDesignSystem.textTertiary,
              ),
              filled: true,
              fillColor: AppDesignSystem.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusMedium,
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusMedium,
                ),
                borderSide: BorderSide(
                  color: AppDesignSystem.surfaceGrey,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusMedium,
                ),
                borderSide: const BorderSide(
                  color: AppDesignSystem.secondaryBlue,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDesignSystem.spacing24,
                vertical: AppDesignSystem.spacing20,
              ),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIndicator() {
    return AnimatedBuilder(
      animation: _feedbackController,
      builder: (context, child) {
        return Transform.scale(
          scale: _feedbackController.value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignSystem.spacing20,
              vertical: AppDesignSystem.spacing16,
            ),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? AppDesignSystem.successGreen.withOpacity(0.1)
                  : AppDesignSystem.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
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
                        const SizedBox(height: AppDesignSystem.spacing4),
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
    );
  }

  Widget _buildBottomActions() {
    // Show Continue button after submission
    if (_hasSubmitted) {
      return Padding(
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
                        const SizedBox(width: AppDesignSystem.spacing8),
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
      );
    }

    // Show Check button before submission
    return ValueListenableBuilder(
      valueListenable: _textController,

      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.all(AppDesignSystem.spacing20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: _textController.text.trim().isEmpty
                    ? null
                    : AppDesignSystem.successGradient,
                color: _textController.text.trim().isEmpty
                    ? AppDesignSystem.surfaceGrey
                    : null,
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusMedium,
                ),
                boxShadow: _textController.text.trim().isEmpty
                    ? null
                    : AppDesignSystem.shadowHigh,
              ),
              child: ElevatedButton(
                onPressed: _textController.text.trim().isEmpty
                    ? null
                    : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMedium,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: _textController.text.trim().isEmpty
                          ? AppDesignSystem.textTertiary
                          : Colors.white,
                    ),
                    const SizedBox(width: AppDesignSystem.spacing12),
                    Text(
                      'CHECK',
                      style: AppDesignSystem.titleLarge.copyWith(
                        color: _textController.text.trim().isEmpty
                            ? AppDesignSystem.textTertiary
                            : Colors.white,
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
    );
  }
}

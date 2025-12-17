import 'package:duo_app/common/resources/app_design_system.dart';
import 'package:flutter/material.dart';

class ButtonCheck extends StatefulWidget {
  final Function() onPressed;
  final String text;
  final bool isEnabled;

  const ButtonCheck({
    super.key,
    required this.onPressed,
    this.text = 'CHECK',
    this.isEnabled = true,
  });

  @override
  State<ButtonCheck> createState() => _ButtonCheckState();
}

class _ButtonCheckState extends State<ButtonCheck>
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
              child: GestureDetector(
                onTapDown: widget.isEnabled
                    ? (_) {
                        setState(() => _isPressed = true);
                        _controller.forward();
                      }
                    : null,
                onTapUp: widget.isEnabled
                    ? (_) {
                        setState(() => _isPressed = false);
                        _controller.reverse();
                        Future.delayed(
                          AppDesignSystem.animationFast,
                          widget.onPressed,
                        );
                      }
                    : null,
                onTapCancel: widget.isEnabled
                    ? () {
                        setState(() => _isPressed = false);
                        _controller.reverse();
                      }
                    : null,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 - (_controller.value * 0.05),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: widget.isEnabled
                              ? AppDesignSystem.successGradient
                              : null,
                          color: widget.isEnabled
                              ? null
                              : AppDesignSystem.surfaceGrey,
                          borderRadius: BorderRadius.circular(
                            AppDesignSystem.radiusMedium,
                          ),
                          boxShadow: widget.isEnabled
                              ? (_isPressed
                                    ? AppDesignSystem.shadowLow
                                    : AppDesignSystem.shadowHigh)
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: widget.isEnabled
                                    ? Colors.white
                                    : AppDesignSystem.textTertiary,
                              ),
                              const SizedBox(width: AppDesignSystem.spacing12),
                              Text(
                                widget.text,
                                style: AppDesignSystem.titleLarge.copyWith(
                                  color: widget.isEnabled
                                      ? Colors.white
                                      : AppDesignSystem.textTertiary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

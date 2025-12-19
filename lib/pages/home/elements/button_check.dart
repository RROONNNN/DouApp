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
      duration: const Duration(milliseconds: 150),
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
      padding: const EdgeInsets.all(20),
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
                          const Duration(milliseconds: 150),
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
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF0D47A1), // Dark Blue
                                    Color(0xFF1976D2), // Primary Blue
                                  ],
                                )
                              : null,
                          color: widget.isEnabled ? null : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: widget.isEnabled
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0D47A1,
                                    ).withOpacity(_isPressed ? 0.2 : 0.4),
                                    blurRadius: _isPressed ? 8 : 15,
                                    offset: Offset(0, _isPressed ? 2 : 8),
                                  ),
                                ]
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
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: widget.isEnabled
                                      ? Colors.white
                                      : Colors.grey[600],
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

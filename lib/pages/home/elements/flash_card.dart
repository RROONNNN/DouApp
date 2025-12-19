import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlashCard extends StatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;
  final Duration flipDuration;
  final double height;
  final double width;
  const FlashCard({
    super.key,
    required this.frontWidget,
    required this.backWidget,
    required this.flipDuration,
    required this.height,
    required this.width,
  });

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _frontAnimation;
  late Animation<double> _backAnimation;
  bool isFrontVisible = true;
  @override
  void initState() {
    _controller = AnimationController(
      duration: widget.flipDuration,
      vsync: this,
    );
    _frontAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween(
          begin: 0.0,
          end: math.pi / 2,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(math.pi / 2),
        weight: 50.0,
      ),
    ]).animate(_controller);
    _backAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(math.pi / 2),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween(
          begin: -math.pi / 2,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 50.0,
      ),
    ]).animate(_controller);

    super.initState();
  }

  void _toggleSide() {
    if (isFrontVisible) {
      _controller.forward();
      isFrontVisible = false;
    } else {
      _controller.reverse();
      isFrontVisible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleSide,
          child: AnimatedCard(
            animation: _frontAnimation,
            height: widget.height,
            width: widget.width,
            child: widget.frontWidget,
          ),
        ),
        GestureDetector(
          onTap: _toggleSide,
          child: AnimatedCard(
            animation: _backAnimation,
            height: widget.height,
            width: widget.width,
            child: widget.backWidget,
          ),
        ),
      ],
    );
  }
}

class AnimatedCard extends StatelessWidget {
  const AnimatedCard({
    required this.child,
    required this.animation,
    required this.height,
    required this.width,
    super.key,
  });

  final Widget child;
  final Animation<double> animation;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: _builder,
      child: SizedBox(
        height: height,
        width: width,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF1976D2).withOpacity(0.3),
              width: 2,
            ),
          ),
          borderOnForeground: false,
          shadowColor: const Color(0xFF1976D2).withOpacity(0.3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(padding: const EdgeInsets.all(10), child: child),
          ),
        ),
      ),
    );
  }

  Widget _builder(BuildContext context, Widget? child) {
    var transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.002);
    transform.rotateY(animation.value);
    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: child,
    );
  }
}

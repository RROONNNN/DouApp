import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TapLottieWidget extends StatefulWidget {
  final String animationPath;
  final double width;
  final double height;
  final String audioPath;
  const TapLottieWidget({
    super.key,
    required this.animationPath,
    required this.width,
    required this.height,
    required this.audioPath,
  });

  @override
  State<TapLottieWidget> createState() => _TapLottieWidgetState();
}

class _TapLottieWidgetState extends State<TapLottieWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _isPlaying = false;
  bool _isInitialized = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Set up listener once
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _controller.reset();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isPlaying) {
        _controller.reset();
        _controller.forward();
      }
    });

    // Initialize audio source after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
    });
  }

  Future<void> _initializeAudio() async {
    if (!mounted || widget.audioPath.isEmpty) {
      return;
    }

    try {
      // Set the new source using setSourceUrl (more reliable for URLs)
      await _audioPlayer.setSourceUrl(widget.audioPath);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        debugPrint('Audio initialized successfully: ${widget.audioPath}');
      }
    } catch (e) {
      debugPrint('Error initializing audio player: $e : ${widget.audioPath}');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    if (!mounted || widget.audioPath.isEmpty) {
      return;
    }

    // If already playing, stop and restart
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
      _controller.reset();
      return;
    }

    // If not initialized yet, try to initialize first
    if (!_isInitialized) {
      await _initializeAudio();
      if (!_isInitialized) {
        debugPrint('Audio not initialized, cannot play');
        return;
      }
    }

    try {
      _controller.forward();
      setState(() {
        _isPlaying = true;
      });
      // Use play() to start from the beginning each time
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Lottie.asset(
        widget.animationPath,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
        repeat: true,
        controller: _controller,
      ),
    );
  }
}

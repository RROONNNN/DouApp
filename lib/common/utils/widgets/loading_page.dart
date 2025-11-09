import 'dart:math';

import 'package:duo_app/common/resources/asset_images.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});
  static const List<String> listLoadingAnimations = [
    AssetImages.loadingCircle,
    AssetImages.smartOwlEducation,
  ];

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final randomIndex = random.nextInt(listLoadingAnimations.length);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Lottie.asset(
          listLoadingAnimations[randomIndex],
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}

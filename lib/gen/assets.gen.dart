// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsAnimationsGen {
  const $AssetsAnimationsGen();

  /// File path: assets/animations/LineSoundIconAnimations.json
  String get lineSoundIconAnimations =>
      'assets/animations/LineSoundIconAnimations.json';

  /// File path: assets/animations/SmartOwlEducation.json
  String get smartOwlEducation => 'assets/animations/SmartOwlEducation.json';

  /// File path: assets/animations/loading_circle.json
  String get loadingCircle => 'assets/animations/loading_circle.json';

  /// List of all assets
  List<String> get values => [
    lineSoundIconAnimations,
    smartOwlEducation,
    loadingCircle,
  ];
}

class $AssetsNavigationIconsGen {
  const $AssetsNavigationIconsGen();

  /// File path: assets/navigation_icons/nav_graph.png
  AssetGenImage get navGraph =>
      const AssetGenImage('assets/navigation_icons/nav_graph.png');

  /// File path: assets/navigation_icons/nav_home.png
  AssetGenImage get navHome =>
      const AssetGenImage('assets/navigation_icons/nav_home.png');

  /// File path: assets/navigation_icons/nav_info.png
  AssetGenImage get navInfo =>
      const AssetGenImage('assets/navigation_icons/nav_info.png');

  /// File path: assets/navigation_icons/nav_remove.png
  AssetGenImage get navRemove =>
      const AssetGenImage('assets/navigation_icons/nav_remove.png');

  /// File path: assets/navigation_icons/nav_user.png
  AssetGenImage get navUser =>
      const AssetGenImage('assets/navigation_icons/nav_user.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    navGraph,
    navHome,
    navInfo,
    navRemove,
    navUser,
  ];
}

class $AssetsSoundsGen {
  const $AssetsSoundsGen();

  /// File path: assets/sounds/correct.mp3
  String get correct => 'assets/sounds/correct.mp3';

  /// File path: assets/sounds/wrong.mp3
  String get wrong => 'assets/sounds/wrong.mp3';

  /// List of all assets
  List<String> get values => [correct, wrong];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $AssetsAnimationsGen animations = $AssetsAnimationsGen();
  static const String example = 'assets/example.json';
  static const String google = 'assets/google.svg';
  static const AssetGenImage level = AssetGenImage('assets/level.png');
  static const AssetGenImage logo = AssetGenImage('assets/logo.png');
  static const $AssetsNavigationIconsGen navigationIcons =
      $AssetsNavigationIconsGen();
  static const $AssetsSoundsGen sounds = $AssetsSoundsGen();

  /// List of all assets
  static List<dynamic> get values => [aEnv, example, google, level, logo];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

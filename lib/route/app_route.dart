import 'package:duo_app/pages/bootstrap/bootstrap_page.dart';
import 'package:duo_app/pages/home/home_page.dart';
import 'package:duo_app/pages/login/login_page.dart';
import 'package:duo_app/pages/login/register_page.dart';
import 'package:duo_app/pages/login/verify_code_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore_for_file: avoid_classes_with_only_static_members
class RouterName {
  static const String boostrap = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyCode = '/verify-code';
}

class AppRoutes {
  static Route<dynamic>? onGenerateRoutes(RouteSettings settings) {
    if (kDebugMode) {
      print('Navigate to:${settings.name ?? ''}');
    }
    switch (settings.name) {
      case RouterName.boostrap:
        return _materialRoute(settings, const BootstrapPage());
      case RouterName.home:
        return _materialRoute(settings, const HomePage());
      case RouterName.login:
        return _materialRoute(settings, const LoginPage());
      case RouterName.register:
        return _materialRoute(settings, const RegisterPage());
      case RouterName.verifyCode:
        final email = settings.arguments as String?;
        return _materialRoute(
          settings,
          VerifyCodePage(email: email ?? ''),
        );
    }
    return null;
  }

  static Route<dynamic> _materialRoute(RouteSettings settings, Widget view) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => view,
    );
  }

  // ignore: unused_element
  static Route<dynamic> _pageRouteBuilderWithPresentEffect(
      RouteSettings settings, Widget view) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          view,
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        const Offset begin = Offset(0.0, 1.0);
        const Offset end = Offset.zero;
        const Cubic curve = Curves.ease;

        final Animatable<Offset> tween = Tween<Offset>(begin: begin, end: end)
            .chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // ignore: unused_element
  static Route<dynamic> _pageRouteBuilderWithFadeEffect(
      RouteSettings settings, Widget view) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      opaque: false,
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          view,
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

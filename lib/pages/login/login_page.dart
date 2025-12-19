import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/utils/validator/validator.dart';
import 'package:duo_app/common/utils/widgets/app_text_field.dart';
import 'package:duo_app/common/utils/widgets/loading_indicator.dart';
import 'package:duo_app/common/utils/widgets/password_field.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/login/bloc/login_bloc.dart';
import 'package:duo_app/pages/login/bloc/login_state.dart';
import 'package:duo_app/pages/login/register_page.dart';
import 'package:duo_app/route/app_route.dart';
import 'package:duo_app/route/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/resources/index.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginBloc _bloc = getIt();
  final GlobalKey<FormState> _key = GlobalKey();

  late AnimationController _slideController;
  late AnimationController _glowController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create staggered slide animations
    _slideAnimations = List.generate(
      6,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                index * 0.1,
                0.6 + (index * 0.1),
                curve: Curves.easeOut,
              ),
            ),
          ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    );

    // Start animations
    _slideController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => _bloc,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E88E5), // Blue 600
                Color(0xFF42A5F5), // Blue 400
              ],
            ),
          ),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              switch (state.requestStatus) {
                case RequestStatus.initial:
                  break;
                case RequestStatus.requesting:
                  IgnoreLoadingIndicator().show(context);
                  break;
                case RequestStatus.success:
                  IgnoreLoadingIndicator().hide(context);
                  AppNavigator.pushNamedAndRemoveUntil(
                    RouterName.navigation,
                    (_) => false,
                  );
                  break;
                case RequestStatus.failed:
                  IgnoreLoadingIndicator().hide(context);
                  if (state.message?.isNotEmpty ?? false) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message ?? 'Login failed'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                  break;
              }
            },
            builder: (context, state) => SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _key,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Avatar with Glow
                        SlideTransition(
                          position: _slideAnimations[0],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_glowController.value * 0.05),
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          Colors.blue.shade50,
                                        ],
                                      ),
                                      boxShadow: [
                                        // Outer glow - animated
                                        BoxShadow(
                                          color: const Color(0xFF1E88E5)
                                              .withOpacity(
                                                0.4 +
                                                    (_glowController.value *
                                                        0.3),
                                              ),
                                          blurRadius:
                                              30 + (_glowController.value * 25),
                                          spreadRadius:
                                              8 + (_glowController.value * 4),
                                        ),
                                        // Mid-layer shadow for depth
                                        BoxShadow(
                                          color: const Color(
                                            0xFF42A5F5,
                                          ).withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 4),
                                        ),
                                        // Inner shadow for depth
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.8),
                                          blurRadius: 10,
                                          spreadRadius: -5,
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.blue.shade50.withOpacity(
                                                0.3,
                                              ),
                                            ],
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/logo.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Welcome Text
                        SlideTransition(
                          position: _slideAnimations[1],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SlideTransition(
                          position: _slideAnimations[1],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Sign in to continue',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Username TextField
                        SlideTransition(
                          position: _slideAnimations[2],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: AppTextField(
                                controller: _usernameController,
                                validator: Validator.nullOrEmptyValidation,
                                hintText: 'Username or Email',
                                onChanged: (value) =>
                                    _bloc.onChangeEmail(value),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password TextField
                        SlideTransition(
                          position: _slideAnimations[3],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: PasswordField(
                                controller: _passwordController,
                                validatePass: true,
                                onChanged: (value) => _bloc.onChangePass(value),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Forgot Password Link
                        SlideTransition(
                          position: _slideAnimations[3],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => AppNavigator.pushNamed(
                                  RouterName.forgotPassword,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SlideTransition(
                          position: _slideAnimations[4],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0D47A1),
                                    Color(0xFF1976D2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0D47A1,
                                    ).withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => onSubmit(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register link
                        SlideTransition(
                          position: _slideAnimations[4],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  ),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Divider with "OR"
                        SlideTransition(
                          position: _slideAnimations[5],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.5),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.5),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Google Sign-In Button
                        SlideTransition(
                          position: _slideAnimations[5],
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: OutlinedButton.icon(
                                onPressed: () => _bloc.googleSignIn(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Image.asset(
                                  'assets/google.svg',
                                  height: 24,
                                  width: 24,
                                ),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onSubmit() {
    if (_key.currentState?.validate() ?? false) {
      _bloc.onLogin();
    }
  }
}

import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/utils/validator/validator.dart';
import 'package:duo_app/common/utils/widgets/app_text_field.dart';
import 'package:duo_app/common/utils/widgets/loading_indicator.dart';
import 'package:duo_app/common/utils/widgets/password_field.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/login/cubit/change_password_cubit.dart';
import 'package:duo_app/route/app_route.dart';
import 'package:duo_app/route/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final ChangePasswordCubit _cubit;
  final GlobalKey<FormState> _formKey = GlobalKey();

  late AnimationController _rotationController;
  late AnimationController _slideController;
  late Animation<double> _rotationAnimation;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ChangePasswordCubit>(param1: widget.email);

    // Rotation animation for key icon
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create staggered slide animations
    _slideAnimations = List.generate(
      4,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                index * 0.15,
                0.5 + (index * 0.15),
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
    _rotationController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rotationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChangePasswordCubit>(
      create: (_) => _cubit,
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
          child: SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => AppNavigator.pop(),
                      ),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Form content
                Expanded(
                  child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
                    listener: (context, state) {
                      switch (state.requestStatus) {
                        case RequestStatus.initial:
                          break;
                        case RequestStatus.requesting:
                          IgnoreLoadingIndicator().show(context);
                          break;
                        case RequestStatus.success:
                          IgnoreLoadingIndicator().hide(context);
                          if (state.message?.isNotEmpty ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message!),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                          // Navigate to login page after successful password reset
                          Future.delayed(const Duration(seconds: 1), () {
                            AppNavigator.pushNamedAndRemoveUntil(
                              RouterName.login,
                              (_) => false,
                            );
                          });
                          break;
                        case RequestStatus.failed:
                          IgnoreLoadingIndicator().hide(context);
                          if (state.message?.isNotEmpty ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message!),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                          break;
                      }
                    },
                    builder: (context, state) {
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Key Icon with rotation
                                RotationTransition(
                                  turns: _rotationAnimation,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF42A5F5),
                                          Color(0xFF1976D2),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.4),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.vpn_key,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Title
                                SlideTransition(
                                  position: _slideAnimations[0],
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: const Text(
                                      'Create New Password',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Email Display
                                SlideTransition(
                                  position: _slideAnimations[0],
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'For ${widget.email}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Code TextField
                                SlideTransition(
                                  position: _slideAnimations[1],
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: AppTextField(
                                        controller: _codeController,
                                        validator:
                                            Validator.nullOrEmptyValidation,
                                        hintText: 'Reset Code',
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) =>
                                            _cubit.onChangeCode(value),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Password TextField
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
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: PasswordField(
                                        controller: _passwordController,
                                        validatePass: true,
                                        placeHolder: 'New Password',
                                        onChanged: (value) =>
                                            _cubit.onChangePassword(value),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password TextField
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
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: PasswordField(
                                        controller: _confirmPasswordController,
                                        validatePass: false,
                                        placeHolder: 'Confirm Password',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Reset Password Button
                                SlideTransition(
                                  position: _slideAnimations[3],
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
                                        onPressed: () => _onResetPassword(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Reset Password',
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

                                // Back to Login
                                SlideTransition(
                                  position: _slideAnimations[3],
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: TextButton(
                                      onPressed: () {
                                        AppNavigator.pushNamedAndRemoveUntil(
                                          RouterName.login,
                                          (_) => false,
                                        );
                                      },
                                      child: const Text(
                                        'Back to Login',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      _cubit.changePassword();
    }
  }
}

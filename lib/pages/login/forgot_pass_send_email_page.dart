import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/utils/validator/validator.dart';
import 'package:duo_app/common/utils/widgets/app_text_field.dart';
import 'package:duo_app/common/utils/widgets/loading_indicator.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/login/cubit/forgot_password_cubit.dart';
import 'package:duo_app/route/app_route.dart';
import 'package:duo_app/route/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final ForgotPasswordCubit _cubit = getIt();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late AnimationController _unlockController;
  late AnimationController _slideController;
  late Animation<double> _unlockAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Unlock animation
    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _unlockAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _unlockController, curve: Curves.easeInOut),
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    );

    // Start animations
    _unlockController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _unlockController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordCubit>(
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
                        'Forgot Password',
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
                  child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
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
                                // Lock Icon with unlock animation
                                AnimatedBuilder(
                                  animation: _unlockAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _unlockAnimation.value * 0.2,
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
                                              color: Colors.blue.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _unlockAnimation.value > 0.5
                                              ? Icons.lock_open
                                              : Icons.lock_reset,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 40),

                                // Title
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: const Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Description
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Text(
                                      'Enter your email address and we\'ll send you a code to reset your password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Email TextField
                                SlideTransition(
                                  position: _slideAnimation,
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
                                        controller: _emailController,
                                        validator: Validator.emailValidation,
                                        hintText: 'Email',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged: (value) =>
                                            _cubit.onChangeEmail(value),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Send Code Button
                                SlideTransition(
                                  position: _slideAnimation,
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
                                        onPressed: () => _onSendCode(),
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
                                          'Send Reset Code',
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

                                // Resend Code Button
                                if (state.codeSent)
                                  SlideTransition(
                                    position: _slideAnimation,
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: TextButton(
                                        onPressed: () => _onSendCode(),
                                        child: const Text(
                                          'Resend Code',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Continue to Change Password Button
                                if (state.codeSent) ...[
                                  const SizedBox(height: 16),
                                  SlideTransition(
                                    position: _slideAnimation,
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2E7D32),
                                              Color(0xFF4CAF50),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _navigateToChangePassword(
                                                state.email!,
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Continue to Reset Password',
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
                                ],
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

  void _onSendCode() {
    if (_formKey.currentState?.validate() ?? false) {
      _cubit.sendResetCode();
    }
  }

  void _navigateToChangePassword(String email) {
    AppNavigator.pushNamed(RouterName.changePassword, arguments: email);
  }
}

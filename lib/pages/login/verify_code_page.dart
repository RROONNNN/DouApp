import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/utils/validator/validator.dart';
import 'package:duo_app/common/utils/widgets/app_text_field.dart';
import 'package:duo_app/common/utils/widgets/loading_indicator.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/login/cubit/verify_code_cubit.dart';
import 'package:duo_app/route/app_route.dart';
import 'package:duo_app/route/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key, required this.email});

  final String email;

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  late final VerifyCodeCubit _cubit;
  final GlobalKey<FormState> _formKey = GlobalKey();

  late AnimationController _bounceController;
  late AnimationController _slideController;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _emailSlideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<VerifyCodeCubit>(param1: widget.email);

    // Bounce animation for icon
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _emailSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    );

    // Start animations
    _bounceController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _bounceController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerifyCodeCubit>(
      create: (_) => _cubit,
      child: BlocConsumer<VerifyCodeCubit, VerifyCodeState>(
        listener: (context, state) {
          switch (state.status) {
            case RequestStatus.initial:
              break;
            case RequestStatus.requesting:
              IgnoreLoadingIndicator().show(context);
              break;
            case RequestStatus.success:
              IgnoreLoadingIndicator().hide(context);
              // Navigate to home page after successful verification
              AppNavigator.pushNamedAndRemoveUntil(
                RouterName.navigation,
                (_) => false,
              );
              break;
            case RequestStatus.failed:
              IgnoreLoadingIndicator().hide(context);
              if (state.message?.isNotEmpty ?? false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message ?? 'Verification failed'),
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
          return Scaffold(
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            'Verify Email',
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
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Email Icon with bounce
                                ScaleTransition(
                                  scale: _bounceAnimation,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4CAF50),
                                          Color(0xFF66BB6A),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.4),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.mark_email_read_outlined,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Title
                                SlideTransition(
                                  position: _emailSlideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: const Text(
                                      'Verification Code',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Info Text
                                SlideTransition(
                                  position: _emailSlideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Text(
                                      'We have sent a verification code to',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Email Display
                                SlideTransition(
                                  position: _emailSlideAnimation,
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
                                        widget.email,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Code TextField
                                SlideTransition(
                                  position: _emailSlideAnimation,
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
                                        hintText: 'Enter verification code',
                                        prefixIcon: const Icon(
                                          Icons.verified_user_outlined,
                                        ),
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) =>
                                            _cubit.onChangeCode(value),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Verify Button
                                SlideTransition(
                                  position: _emailSlideAnimation,
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
                                        onPressed: () => _onSubmit(),
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
                                          'Verify Email',
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

                                // Resend code option
                                SlideTransition(
                                  position: _emailSlideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Didn't receive the code?",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: Implement resend code logic
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Resend code feature coming soon',
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Resend Code',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _cubit.onVerifyCode();
    }
  }
}

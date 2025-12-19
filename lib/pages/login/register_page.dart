import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/utils/validator/validator.dart';
import 'package:duo_app/common/utils/widgets/app_text_field.dart';
import 'package:duo_app/common/utils/widgets/loading_indicator.dart';
import 'package:duo_app/common/utils/widgets/password_field.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/login/cubit/register_cubit.dart';
import 'package:duo_app/pages/login/verify_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final RegisterCubit _cubit = getIt();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late AnimationController _slideController;
  late AnimationController _rotationController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered slide animations
    _slideAnimations = List.generate(
      5,
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

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );

    // Start animations
    _slideController.forward();
    _rotationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) => _cubit,
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          switch (state.requestStatus) {
            case RequestStatus.initial:
              break;
            case RequestStatus.requesting:
              IgnoreLoadingIndicator().show(context);
              break;
            case RequestStatus.success:
              IgnoreLoadingIndicator().hide(context);
              // Navigate to verify code page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VerifyCodePage(email: state.email ?? ''),
                ),
              );
              break;
            case RequestStatus.failed:
              IgnoreLoadingIndicator().hide(context);
              if (state.message?.isNotEmpty ?? false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message ?? 'Registration failed'),
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
                            'Create Account',
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
                                // Registration Icon with rotation
                                SlideTransition(
                                  position: _slideAnimations[0],
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: RotationTransition(
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
                                              color: Colors.blue.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person_add,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
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
                                      'Join Us Today!',
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
                                  position: _slideAnimations[0],
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Text(
                                      'Create your account to get started',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Full Name TextField
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
                                        controller: _fullNameController,
                                        validator:
                                            Validator.nullOrEmptyValidation,
                                        hintText: 'Full Name',
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                        ),
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.name,
                                        onChanged: (value) =>
                                            _cubit.onChangeFullName(value),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Email TextField
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
                                      child: AppTextField(
                                        controller: _emailController,
                                        validator:
                                            Validator.nullOrEmptyValidation,
                                        hintText: 'Email',
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        onChanged: (value) =>
                                            _cubit.onChangeEmail(value),
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
                                        onChanged: (value) =>
                                            _cubit.onChangePassword(value),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Register Button
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
                                          'Register',
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

                                // Already have account
                                SlideTransition(
                                  position: _slideAnimations[4],
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Already have an account? ',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
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
      _cubit.onRegister();
    }
  }
}

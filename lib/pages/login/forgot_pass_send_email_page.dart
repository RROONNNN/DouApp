import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/resources/index.dart';
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

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final ForgotPasswordCubit _cubit = getIt();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordCubit>(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => AppNavigator.pop(),
          ),
          title: const Text(
            'Forgot Password',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
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
                      // Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset,
                          size: 50,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      const Text(
                        'Enter your email address and we\'ll send you a code to reset your password',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email TextField
                      AppTextField(
                        controller: _emailController,
                        validator: Validator.emailValidation,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => _cubit.onChangeEmail(value),
                      ),
                      const SizedBox(height: 24),

                      // Send Code Button
                      ElevatedButton(
                        onPressed: () => _onSendCode(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Send Reset Code',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resend Code Button
                      if (state.codeSent)
                        TextButton(
                          onPressed: () => _onSendCode(),
                          child: Text(
                            'Resend Code',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Continue to Change Password Button
                      if (state.codeSent) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              _navigateToChangePassword(state.email!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue to Reset Password',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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

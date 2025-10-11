import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/resources/index.dart';
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

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final ChangePasswordCubit _cubit;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ChangePasswordCubit>(param1: widget.email);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChangePasswordCubit>(
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
            'Reset Password',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
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
                          Icons.vpn_key,
                          size: 50,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Create New Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Email Display
                      Text(
                        'For ${widget.email}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Code TextField
                      AppTextField(
                        controller: _codeController,
                        validator: Validator.nullOrEmptyValidation,
                        hintText: 'Reset Code',
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _cubit.onChangeCode(value),
                      ),
                      const SizedBox(height: 16),

                      // Password TextField
                      PasswordField(
                        controller: _passwordController,
                        validatePass: true,
                        placeHolder: 'New Password',
                        onChanged: (value) => _cubit.onChangePassword(value),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password TextField
                      PasswordField(
                        controller: _confirmPasswordController,
                        validatePass: false,
                        placeHolder: 'Confirm Password',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Reset Password Button
                      ElevatedButton(
                        onPressed: () => _onResetPassword(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Back to Login
                      TextButton(
                        onPressed: () {
                          AppNavigator.pushNamedAndRemoveUntil(
                            RouterName.login,
                            (_) => false,
                          );
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
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
    );
  }

  void _onResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      _cubit.changePassword();
    }
  }
}

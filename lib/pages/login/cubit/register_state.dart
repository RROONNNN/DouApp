part of 'register_cubit.dart';

class RegisterState extends Equatable {
  final String? email;
  final String? password;
  final String? fullName;
  final RequestStatus requestStatus;
  final String? message;

  const RegisterState({
    this.email,
    this.password,
    this.fullName,
    this.requestStatus = RequestStatus.initial,
    this.message,
  });

  RegisterState copyWith({
    String? email,
    String? password,
    String? fullName,
    RequestStatus? requestStatus,
    String? message,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      requestStatus: requestStatus ?? this.requestStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [email, password, fullName, requestStatus, message];
}

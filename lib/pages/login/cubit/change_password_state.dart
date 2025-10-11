part of 'change_password_cubit.dart';

class ChangePasswordState extends Equatable {
  final RequestStatus requestStatus;
  final String email;
  final String? code;
  final String? password;
  final String? message;

  const ChangePasswordState({
    this.requestStatus = RequestStatus.initial,
    required this.email,
    this.code,
    this.password,
    this.message,
  });

  @override
  List<Object?> get props => [requestStatus, email, code, password, message];

  ChangePasswordState copyWith({
    RequestStatus? requestStatus,
    String? email,
    String? code,
    String? password,
    String? message,
  }) {
    return ChangePasswordState(
      requestStatus: requestStatus ?? this.requestStatus,
      email: email ?? this.email,
      code: code ?? this.code,
      password: password ?? this.password,
      message: message,
    );
  }
}

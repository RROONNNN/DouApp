part of 'forgot_password_cubit.dart';

class ForgotPasswordState extends Equatable {
  final RequestStatus requestStatus;
  final String? email;
  final bool codeSent;
  final String? message;

  const ForgotPasswordState({
    this.requestStatus = RequestStatus.initial,
    this.email,
    this.codeSent = false,
    this.message,
  });

  @override
  List<Object?> get props => [requestStatus, email, codeSent, message];

  ForgotPasswordState copyWith({
    RequestStatus? requestStatus,
    String? email,
    bool? codeSent,
    String? message,
  }) {
    return ForgotPasswordState(
      requestStatus: requestStatus ?? this.requestStatus,
      email: email ?? this.email,
      codeSent: codeSent ?? this.codeSent,
      message: message,
    );
  }
}

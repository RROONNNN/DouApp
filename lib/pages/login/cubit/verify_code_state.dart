part of 'verify_code_cubit.dart';

class VerifyCodeState extends Equatable {
  final String email;
  final String? code;
  final RequestStatus status;
  final String? message;
  const VerifyCodeState(
      {required this.email,
      this.code,
      this.status = RequestStatus.initial,
      this.message});

  VerifyCodeState copyWith({
    String? code,
    RequestStatus? status,
    String? message,
  }) {
    return VerifyCodeState(
        email: email,
        code: code ?? this.code,
        status: status ?? this.status,
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [email, code, status, message];
}

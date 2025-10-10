import 'package:duo_app/common/enums/request_status.dart';

class LoginState {
  String? email;
  String? password;
  String? message;
  RequestStatus requestStatus;

  LoginState({
    this.email,
    this.password,
    this.message,
    this.requestStatus = RequestStatus.initial,
  });

  LoginState copyWith({
    String? email,
    String? password,
    String? message,
    RequestStatus? requestStatus,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      message: message ?? this.message,
      requestStatus: requestStatus ?? RequestStatus.initial,
    );
  }
}

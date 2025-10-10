bool showLogout = false;

class LogoutEvent {
  String? message;

  LogoutEvent({this.message});
}

class LoginEvent {}

class NetworkStatusChangeEvent {
  NetworkStatusChangeEvent({this.status = true});
  final bool status;
}

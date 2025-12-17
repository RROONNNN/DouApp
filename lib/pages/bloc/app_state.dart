import 'package:duo_app/entities/user.dart';
import 'package:duo_app/pages/profile/cubit/profile_cubit.dart';

class AppState {
  final ProfileStatus status;
  final User? user;

  const AppState({this.status = ProfileStatus.initial, this.user});
  AppState copyWith({ProfileStatus? status, User? user}) =>
      AppState(status: status ?? this.status, user: user ?? this.user);
}

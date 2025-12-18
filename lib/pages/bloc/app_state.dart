import 'package:duo_app/entities/course.dart';
import 'package:duo_app/entities/user.dart';
import 'package:duo_app/pages/bloc/app_bloc.dart';

class AppState {
  final ProfileStatus status;
  final User? user;
  final Course? currentCourse;

  const AppState({
    this.status = ProfileStatus.initial,
    this.user,
    this.currentCourse,
  });
  AppState copyWith({
    ProfileStatus? status,
    User? user,
    Course? currentCourse,
  }) => AppState(
    status: status ?? this.status,
    user: user ?? this.user,
    currentCourse: currentCourse ?? this.currentCourse,
  );
  @override
  List<Object?> get props => [status, user, currentCourse];
}

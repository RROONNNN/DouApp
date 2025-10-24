part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = RequestStatus.initial,
    this.selectedCourse,
    this.courses = const [],
    this.units = const [],
  });

  final RequestStatus status;
  final Course? selectedCourse;
  final List<Course> courses;
  final List<Unit> units;
  @override
  List<Object?> get props => [status, selectedCourse, courses, units];
}

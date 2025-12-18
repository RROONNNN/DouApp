part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = RequestStatus.initial,
    this.coursesStatus = RequestStatus.initial,
    this.selectedCourse,
    this.courses = const [],
    this.units = const [],
  });

  final RequestStatus status;
  final Course? selectedCourse;
  final List<Course> courses;
  final RequestStatus coursesStatus;
  final List<Unit> units;
  @override
  List<Object?> get props => [
    status,
    selectedCourse,
    courses,
    coursesStatus,
    units,
  ];
  HomeState copyWith({
    RequestStatus? status,
    Course? selectedCourse,
    List<Course>? courses,
    RequestStatus? coursesStatus,
    List<Unit>? units,
  }) {
    return HomeState(
      status: status ?? this.status,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      courses: courses ?? this.courses,
      coursesStatus: coursesStatus ?? this.coursesStatus,
      units: units ?? this.units,
    );
  }
}

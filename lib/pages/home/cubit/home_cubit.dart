import 'package:bloc/bloc.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/remote/learning_service.dart';
import 'package:duo_app/entities/course.dart';
import 'package:duo_app/entities/unit.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';

@singleton
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.learningService}) : super(const HomeState());
  final LearningService learningService;
  Future<void> initialize() async {
    try {
      if (isClosed) return;
      emit(state.copyWith(status: RequestStatus.requesting));
      final progress = await learningService.getProgress();
      late final Course currentCourse;
      List<Course> courses = [];
      if (progress != null) {
        final courseId = progress.course;
        currentCourse = await learningService.getCourseById(courseId);
        final units = await learningService.getUnitsByCourseId(courseId);
        if (units.isNotEmpty) {
          final selectedUnit = units.first;
          final lessons = await learningService.getTheoriesByUnitId(
            selectedUnit.id,
          );
        }
      } else {
        courses = await learningService.getCourses();
        if (courses.isNotEmpty) {
          currentCourse = courses.first;
        }
        if (isClosed) return;
      }
      final units = await learningService.getUnitsByCourseId(currentCourse.id);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RequestStatus.success,
          selectedCourse: currentCourse,
          courses: courses,
          units: units,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: RequestStatus.failed));
    }
  }

  Future<void> loadCourses() async {
    try {
      if (isClosed) return;
      emit(state.copyWith(coursesStatus: RequestStatus.requesting));
      final courses = await learningService.getCourses();

      if (isClosed) return;
      emit(
        state.copyWith(coursesStatus: RequestStatus.success, courses: courses),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(coursesStatus: RequestStatus.failed));
    }
  }

  Future<void> selectCourse(String courseId) async {
    try {
      if (isClosed) return;
      emit(state.copyWith(status: RequestStatus.requesting));
      final course = await learningService.getCourseById(courseId);
      final units = await learningService.getUnitsByCourseId(courseId);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RequestStatus.success,
          selectedCourse: course,
          units: units,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: RequestStatus.failed));
    }
  }
}

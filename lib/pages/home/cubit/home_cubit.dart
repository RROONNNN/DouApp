import 'package:bloc/bloc.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/remote/learning_service.dart';
import 'package:duo_app/entities/course.dart';
import 'package:duo_app/entities/unit.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.learningService}) : super(const HomeState());
  final LearningService learningService;
  Future<void> initialize() async {
    try {
      if (isClosed) return;
      emit(const HomeState(status: RequestStatus.requesting));
      final courses = await learningService.getCourses();
      if (isClosed) return;
      if (courses.isNotEmpty) {
        final selectedCourse = courses.first;
        final units = await learningService.getUnitsByCourseId(
          selectedCourse.id,
        );
        if (isClosed) return;
        emit(
          HomeState(
            status: RequestStatus.success,
            selectedCourse: selectedCourse,
            courses: courses,
            units: units,
          ),
        );
      } else {
        emit(const HomeState(status: RequestStatus.success));
      }
    } catch (e) {
      if (isClosed) return;
      emit(const HomeState(status: RequestStatus.failed));
    }
  }
}

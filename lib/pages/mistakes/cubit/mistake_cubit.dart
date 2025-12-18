import 'package:bloc/bloc.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/remote/learning_service.dart';
import 'package:duo_app/entities/question.dart';
import 'package:duo_app/entities/unit.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'mistake_state.dart';

@injectable
class MistakeCubit extends Cubit<MistakeState> {
  final LearningService learningService;
  MistakeCubit({required this.learningService}) : super(const MistakeState());

  Future<void> getMistakes() async {
    if (isClosed) return;
    emit(state.copyWith(status: RequestStatus.requesting));
    try {
      final mistakes = await learningService.getMistakes();
      if (!isClosed) {
        emit(state.copyWith(status: RequestStatus.success, mistakes: mistakes));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(status: RequestStatus.failed));
      }
    }
  }
}

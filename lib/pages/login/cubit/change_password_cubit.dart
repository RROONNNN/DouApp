import 'package:bloc/bloc.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'change_password_state.dart';

@injectable
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._authService, @factoryParam String? email)
    : super(ChangePasswordState(email: email ?? ''));

  final AuthenticationService _authService;

  void onChangeCode(String code) {
    emit(state.copyWith(code: code));
  }

  void onChangePassword(String password) {
    emit(state.copyWith(password: password));
  }

  Future<void> changePassword() async {
    if (state.email.isEmpty || state.code == null || state.password == null) {
      emit(
        state.copyWith(
          requestStatus: RequestStatus.failed,
          message: 'Please fill all fields',
        ),
      );
      return;
    }

    if (state.password!.length < 6) {
      emit(
        state.copyWith(
          requestStatus: RequestStatus.failed,
          message: 'Password must be at least 6 characters',
        ),
      );
      return;
    }

    emit(state.copyWith(requestStatus: RequestStatus.requesting));

    final result = await _authService.changePassword(
      state.email,
      state.code!,
      state.password!,
    );

    if (result.error == null) {
      emit(
        state.copyWith(
          requestStatus: RequestStatus.success,
          message: 'Password changed successfully',
        ),
      );
    } else {
      emit(
        state.copyWith(
          requestStatus: RequestStatus.failed,
          message: result.error ?? 'Failed to change password',
        ),
      );
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'forgot_password_state.dart';

@injectable
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._authService) : super(const ForgotPasswordState());

  final AuthenticationService _authService;

  void onChangeEmail(String email) {
    emit(state.copyWith(email: email));
  }

  Future<void> sendResetCode() async {
    if (state.email == null || state.email!.isEmpty) {
      emit(
        state.copyWith(
          requestStatus: RequestStatus.failed,
          message: 'Please enter your email',
        ),
      );
      return;
    }

    emit(state.copyWith(requestStatus: RequestStatus.requesting));

    final result = await _authService.forgotPassword(state.email!);

    if (result.error == null) {
      emit(
        state.copyWith(
          requestStatus: RequestStatus.success,
          codeSent: true,
          message: 'Reset code sent successfully',
        ),
      );
    } else {
      emit(
        state.copyWith(
          requestStatus: RequestStatus.failed,
          message: result.error ?? 'Failed to send reset code',
        ),
      );
    }
  }
}

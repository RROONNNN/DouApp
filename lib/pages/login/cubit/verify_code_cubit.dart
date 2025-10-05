import 'package:bloc/bloc.dart';
import 'package:duo_app/common/api_client/data_state.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/remote/authentication/login_response.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'verify_code_state.dart';

@Injectable()
class VerifyCodeCubit extends Cubit<VerifyCodeState> {
  VerifyCodeCubit(
    @factoryParam this.email,
    this._authenticationService,
  ) : super(VerifyCodeState(email: email));

  final String email;
  final AuthenticationService _authenticationService;

  void onChangeCode(String? value) {
    emit(state.copyWith(code: value));
  }

  void onVerifyCode() async {
    if (state.code == null || state.code!.isEmpty) {
      emit(state.copyWith(
        status: RequestStatus.failed,
        message: 'Please enter verification code',
      ));
      return;
    }

    emit(state.copyWith(status: RequestStatus.requesting));

    try {
      final DataState<LoginResponse> result =
          await _authenticationService.verifyEmail(
        state.email,
        state.code!,
      );

      if (result is DataSuccess<LoginResponse>) {
        emit(state.copyWith(
          status: RequestStatus.success,
          message: 'Email verified successfully',
        ));
      } else if (result is DataFailed<LoginResponse>) {
        emit(state.copyWith(
          status: RequestStatus.failed,
          message: result.error ?? 'Verification failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RequestStatus.failed,
        message: e.toString(),
      ));
    }
  }
}

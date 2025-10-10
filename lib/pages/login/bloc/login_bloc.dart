import 'package:duo_app/common/api_client/data_state.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/event/event_bus_event.dart';
import 'package:duo_app/common/event/event_bus_mixin.dart';
import 'package:duo_app/data/local/local_service.dart';
import 'package:duo_app/data/remote/authentication/login_request.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:duo_app/pages/login/bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class LoginBloc extends Cubit<LoginState> {
  LoginBloc(this._authenticationService, this._localService)
    : super(LoginState());

  final AuthenticationService _authenticationService;
  final LocalService _localService;

  void onChangeEmail(String? value) {
    emit(state.copyWith(email: value));
  }

  void onChangePass(String? value) {
    emit(state.copyWith(password: value));
  }

  Future<void> onLogin() async {
    try {
      emit(state.copyWith(requestStatus: RequestStatus.requesting));
      if (state.email == null || state.password == null) {
        emit(
          state.copyWith(
            requestStatus: RequestStatus.failed,
            message: 'Please fill all fields',
          ),
        );
        return;
      }
      final result = await _authenticationService.login(
        LoginRequest(email: state.email!, password: state.password!),
      );
      if (result is DataSuccess<bool>) {
        if (result.data == false) {
          emit(
            state.copyWith(
              requestStatus: RequestStatus.failed,
              message: 'Login failed',
            ),
          );
          return;
        }
        emit(state.copyWith(requestStatus: RequestStatus.success));
        EventBusMixin.shareStaticEvent(LoginEvent());
      } else {
        emit(
          state.copyWith(
            requestStatus: RequestStatus.failed,
            message: result.error,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(requestStatus: RequestStatus.failed));
    }
  }
}

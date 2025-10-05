import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/local/local_service.dart';
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

  void onChangeUsername(String? value) {
    emit(state.copyWith(username: value));
  }

  void onChangePass(String? value) {
    emit(state.copyWith(password: value));
  }

  Future<void> onLogin() async {
    try {
      emit(state.copyWith(requestStatus: RequestStatus.requesting));

      // final result = await _authenticationService.login(LoginRequest(
      //     username: state.username, password: state.password, database: db));
      // if (result.isSuccess) {
      //   _localService.saveToken(result.data?.token);
      //   _localService.saveLoginId(state.username);
      //   emit(state.copyWith(requestStatus: RequestStatus.success));
      // } else {
      //   emit(state.copyWith(
      //       requestStatus: RequestStatus.failed, message: result.error));
      // }
    } catch (e) {
      emit(state.copyWith(requestStatus: RequestStatus.failed));
    }
  }
}

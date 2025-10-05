import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/data/remote/authentication/register_request.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'register_state.dart';

@Injectable()
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._authenticationService) : super(const RegisterState());

  final AuthenticationService _authenticationService;

  void onChangeEmail(String? value) {
    emit(state.copyWith(email: value));
  }

  void onChangePassword(String? value) {
    emit(state.copyWith(password: value));
  }

  void onChangeFullName(String? value) {
    emit(state.copyWith(fullName: value));
  }

  void onRegister() async {
    emit(state.copyWith(requestStatus: RequestStatus.requesting));
    try {
      if (state.email == null ||
          state.password == null ||
          state.fullName == null) {
        emit(state.copyWith(
            requestStatus: RequestStatus.failed,
            message: 'Please fill all fields'));
        return;
      }
      final result = await _authenticationService.register(RegisterRequest(
        email: state.email!,
        password: state.password!,
        fullName: state.fullName!,
      ));
      if (result.error == null) {
        emit(state.copyWith(
            requestStatus: RequestStatus.success,
            message: result.data ?? "Check your email to verify your account"));
      } else {
        emit(state.copyWith(
            requestStatus: RequestStatus.failed,
            message: result.error ?? "Register failed"));
      }
    } catch (e) {
      emit(state.copyWith(
          requestStatus: RequestStatus.failed, message: e.toString()));
    }
  }
}

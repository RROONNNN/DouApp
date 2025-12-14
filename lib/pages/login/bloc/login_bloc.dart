import 'dart:async';

import 'package:duo_app/common/api_client/data_state.dart';
import 'package:duo_app/common/enums/request_status.dart';
import 'package:duo_app/common/event/event_bus_event.dart';
import 'package:duo_app/common/event/event_bus_mixin.dart';
import 'package:duo_app/config/google_config.dart';
import 'package:duo_app/data/local/local_service.dart';
import 'package:duo_app/data/remote/authentication/google_login_request.dart';
import 'package:duo_app/data/remote/authentication/login_request.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:duo_app/pages/login/bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

const List<String> scopes = <String>['email', 'profile'];

@Injectable()
class LoginBloc extends Cubit<LoginState> {
  LoginBloc(this._authenticationService, this._localService)
    : super(LoginState()) {
    signIn = GoogleSignIn.instance;
    unawaited(
      signIn
          .initialize(
            clientId: GoogleConfig.androidClientId,
            serverClientId: GoogleConfig.serverClientId,
          )
          .then((_) {
            signIn.authenticationEvents
                .listen(_handleAuthenticationEvent)
                .onError(_handleAuthenticationError);

            signIn.attemptLightweightAuthentication();
          }),
    );
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user == null) {
      // User signed out
      return;
    }

    try {
      emit(state.copyWith(requestStatus: RequestStatus.requesting));

      // Get server authorization code using authorizeServer
      final GoogleSignInServerAuthorization? serverAuth = await user
          .authorizationClient
          .authorizeServer(scopes);

      if (serverAuth == null) {
        emit(
          state.copyWith(
            requestStatus: RequestStatus.failed,
            message: 'Failed to get server auth code',
          ),
        );
        return;
      }

      final result = await _authenticationService.googleLogin(
        GoogleLoginRequest(code: serverAuth.serverAuthCode),
      );

      if (result is DataSuccess<bool>) {
        if (result.data == true) {
          emit(state.copyWith(requestStatus: RequestStatus.success));
          EventBusMixin.shareStaticEvent(LoginEvent());
        } else {
          emit(
            state.copyWith(
              requestStatus: RequestStatus.failed,
              message: 'Google Sign-In failed',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            requestStatus: RequestStatus.failed,
            message: result.error,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          requestStatus: RequestStatus.failed,
          message: 'Google Sign-In error: $e',
        ),
      );
    }
  }

  void _handleAuthenticationError(Object error) {
    emit(
      state.copyWith(
        requestStatus: RequestStatus.failed,
        message: 'Google Sign-In failed: $error',
      ),
    );
  }

  final AuthenticationService _authenticationService;
  final LocalService _localService;
  late final GoogleSignIn signIn;

  void onChangeEmail(String? value) {
    emit(state.copyWith(email: value));
  }

  void onChangePass(String? value) {
    emit(state.copyWith(password: value));
  }

  /// Trigger Google Sign-In flow
  /// The authentication will be handled automatically by _handleAuthenticationEvent
  Future<void> googleSignIn() async {
    try {
      print('🔵 Starting Google Sign-In...');
      print('🔵 ClientId: ${GoogleConfig.androidClientId}');
      print('🔵 ServerClientId: ${GoogleConfig.serverClientId}');

      final account = await signIn.authenticate();

      print('✅ Google Sign-In successful: ${account.email}');
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      emit(
        state.copyWith(
          requestStatus: RequestStatus.failed,
          message: 'Google Sign-In error: $e',
        ),
      );
    }
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

import 'dart:developer';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:duo_app/common/event/event_bus_event.dart';
import 'package:duo_app/data/local/local_service.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:duo_app/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../common/event/event_bus_mixin.dart';
import 'bootstrap_state.dart';

@LazySingleton()
class BootstrapCubit extends Cubit<BootstrapState> with EventBusMixin {
  BootstrapCubit(this._localService)
    : super(const BootstrapState(status: BootstrapStatus.initial)) {
    listenEvent<LogoutEvent>((e) => _handleLogout());
    listenEvent<LoginEvent>((e) => _handleLogin());
  }

  final LocalService _localService;
  Future<void> _handleLogout() async {
    try {
      final cookieJar = getIt<PersistCookieJar>(instanceName: 'cookieJar');
      await cookieJar.deleteAll();
      log('Old status: ${state.status}');
      emit(state.copyWith(status: BootstrapStatus.unauthenticated));
    } catch (e) {
      log('BootstrapCubit _handleLogout  error: ${e.toString()}');
    }
  }

  Future<void> _handleLogin() async {
    emit(state.copyWith(status: BootstrapStatus.authenticated));
  }

  Future<void> initData() async {
    try {
      final refreshToken = _localService.getRefreshToken();
      if (refreshToken == null) {
        emit(state.copyWith(status: BootstrapStatus.unauthenticated));
        return;
      }
      final authenticationService = getIt<AuthenticationService>();
      final result = await authenticationService.refreshToken(refreshToken);

      if (result.error == null) {
        emit(state.copyWith(status: BootstrapStatus.authenticated));
      } else {
        emit(state.copyWith(status: BootstrapStatus.unauthenticated));
      }
    } catch (e) {
      log('BootstrapCubit error: ${e.toString()}');
      emit(state.copyWith(status: BootstrapStatus.unauthenticated));
    }
  }
}

import 'dart:developer';

import 'package:duo_app/configs/build_config.dart';
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
      : super(const BootstrapState(status: BootstrapStatus.initial));

  final LocalService _localService;

  @override
  void emit(BootstrapState state) {
    if (isClosed) {
      return;
    }
    super.emit(state);
  }

  Future<void> initData() async {
    try {
      final refreshToken = _localService.getRefreshToken();
      if (refreshToken.isEmpty) {
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

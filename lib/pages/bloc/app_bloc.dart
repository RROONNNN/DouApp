import 'dart:developer';

import 'package:duo_app/common/event/event_bus_event.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../common/event/event_bus_mixin.dart';
import 'app_state.dart';

enum ProfileStatus { initial, loading, success, failure }

@Singleton()
class AppBloc extends Cubit<AppState> with EventBusMixin {
  AppBloc(this.authenticationService) : super(const AppState());
  final AuthenticationService authenticationService;
  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final result = await authenticationService.getProfile();
      if (result.error == null) {
        emit(state.copyWith(status: ProfileStatus.success, user: result.data));
      } else {
        emit(state.copyWith(status: ProfileStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure));
    }
  }

  void logOut() async {
    try {
      await authenticationService.logout();
      EventBusMixin.shareStaticEvent(LogoutEvent());
    } catch (e) {
      log('ProfileCubit error: ${e.toString()}');
    }
  }
}

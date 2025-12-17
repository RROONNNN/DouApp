import 'dart:developer';

import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:duo_app/pages/profile/cubit/profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../common/event/event_bus_mixin.dart';
import 'app_state.dart';

@Singleton()
class AppBloc extends Cubit<AppState> with EventBusMixin {
  AppBloc(this.authenticationService) : super(const AppState());
  final AuthenticationService authenticationService;
  void loadProfile() async {
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
}

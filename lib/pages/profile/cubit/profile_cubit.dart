import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:duo_app/common/event/event_bus_event.dart';
import 'package:duo_app/data/remote/authentication_service.dart';
import 'package:duo_app/entities/user.dart';

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:duo_app/common/event/event_bus_mixin.dart';
part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.authenticationService) : super(const ProfileState());
  final AuthenticationService authenticationService;

  void loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final result = await authenticationService.getProfile();
      if (result.error == null) {
        emit(state.copyWith(status: ProfileStatus.success, user: result.data));
      } else {
        emit(
          state.copyWith(status: ProfileStatus.failure, message: result.error),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.failure, message: e.toString()),
      );
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

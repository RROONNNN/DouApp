import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../common/event/event_bus_mixin.dart';
import 'app_state.dart';

@Singleton()
class AppBloc extends Cubit<AppState> with EventBusMixin {
  AppBloc() : super(const AppState());
}

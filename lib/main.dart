import 'dart:developer';

import 'package:duo_app/app.dart';
import 'package:duo_app/configs/build_config.dart';
import 'package:duo_app/di/injection.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.prod,
  );
  await configureDependencies(environment);
  final BuildConfig buildConfig = getIt<BuildConfig>();
  if (buildConfig.debugLog) {
    Bloc.observer = AppBlocObserver();
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MyApp());
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('${bloc.runtimeType} $change');
  }
}

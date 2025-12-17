import 'package:duo_app/common/resources/app_colors.dart';
import 'package:duo_app/configs/build_config.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/entities/theory.dart';
import 'package:duo_app/pages/bloc/app_bloc.dart';
import 'package:duo_app/pages/bootstrap/bootstrap_cubit.dart';
import 'package:duo_app/pages/bootstrap/bootstrap_state.dart';
import 'package:duo_app/route/app_route.dart';
import 'package:duo_app/route/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppBloc _appBloc;
  late final BootstrapCubit _bootstrapCubit;
  @override
  void initState() {
    super.initState();
    _appBloc = getIt<AppBloc>();
    _bootstrapCubit = getIt<BootstrapCubit>();
  }

  @override
  Widget build(BuildContext context) {
    _configOrientation(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>.value(value: _appBloc),
        BlocProvider<BootstrapCubit>.value(value: _bootstrapCubit),
      ],
      child: BlocListener<BootstrapCubit, BootstrapState>(
        listener: _handleStateListener,
        child: MaterialApp(
          title: getIt<BuildConfig>().kDefaultAppName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.primaryColor,
          ),
          navigatorKey: AppNavigator.navigatorKey,
          initialRoute: RouterName.boostrap,
          onGenerateRoute: AppRoutes.onGenerateRoutes,
        ),
      ),
    );
  }

  void _configOrientation(BuildContext context) {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  void _handleStateListener(BuildContext context, BootstrapState state) {
    switch (state.status) {
      case BootstrapStatus.authenticated:
        Future.delayed(const Duration(seconds: 2)).then((value) {
          _appBloc.loadProfile();
          AppNavigator.pushNamedAndRemoveUntil(
            RouterName.navigation,
            (_) => false,
          );
        });
        break;
      case BootstrapStatus.unauthenticated:
        Future.delayed(const Duration(seconds: 1)).then((value) {
          AppNavigator.pushNamedAndRemoveUntil(RouterName.login, (_) => false);
        });
        break;
      case BootstrapStatus.initial:
        break;
    }
  }
}

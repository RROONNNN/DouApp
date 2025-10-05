import 'package:duo_app/common/resources/app_colors.dart';
import 'package:duo_app/configs/build_config.dart';
import 'package:duo_app/di/injection.dart';
import 'package:duo_app/pages/bloc/app_bloc.dart';
import 'package:duo_app/route/app_route.dart';
import 'package:duo_app/route/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppBloc _appBloc;
  @override
  void initState() {
    super.initState();
    _appBloc = getIt<AppBloc>();
  }

  @override
  Widget build(BuildContext context) {
    _configOrientation(context);
    return BlocProvider<AppBloc>(
      create: (_) => _appBloc,
      child: MaterialApp(
        title: getIt<BuildConfig>().kDefaultAppName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppColors.primaryColor,
        ),
        navigatorKey: AppNavigator.navigatorKey,
        onGenerateRoute: AppRoutes.onGenerateRoutes,
      ),
    );
  }
}

void _configOrientation(BuildContext context) {
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

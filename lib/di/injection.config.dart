// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:duo_app/common/api_client/api_client.dart' as _i377;
import 'package:duo_app/configs/build_config.dart' as _i718;
import 'package:duo_app/data/local/local_service.dart' as _i373;
import 'package:duo_app/data/local/shared_prefs.dart' as _i368;
import 'package:duo_app/data/remote/authentication_service.dart' as _i432;
import 'package:duo_app/di/modules.dart' as _i920;
import 'package:duo_app/pages/bloc/app_bloc.dart' as _i230;
import 'package:duo_app/pages/bootstrap/bootstrap_cubit.dart' as _i427;
import 'package:duo_app/pages/login/bloc/login_bloc.dart' as _i537;
import 'package:duo_app/pages/login/cubit/register_cubit.dart' as _i1065;
import 'package:duo_app/pages/login/cubit/verify_code_cubit.dart' as _i131;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final injectableModule = _$InjectableModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => injectableModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i230.AppBloc>(() => _i230.AppBloc());
    gh.lazySingleton<_i361.Dio>(() => injectableModule.dio);
    gh.lazySingleton<_i718.BuildConfig>(() => _i718.BuildConfigProd());
    gh.singleton<_i377.ApiClient>(() => _i377.ApiClient(dio: gh<_i361.Dio>()));
    gh.lazySingleton<_i368.SharedPrefs>(
        () => _i368.SharedPrefs(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i373.LocalService>(
        () => _i373.LocalServiceImplement(gh<_i368.SharedPrefs>()));
    gh.lazySingleton<_i432.AuthenticationService>(
        () => _i432.AuthenticationServiceImplement(gh<_i377.ApiClient>()));
    gh.factory<_i1065.RegisterCubit>(
        () => _i1065.RegisterCubit(gh<_i432.AuthenticationService>()));
    gh.factory<_i537.LoginBloc>(() => _i537.LoginBloc(
          gh<_i432.AuthenticationService>(),
          gh<_i373.LocalService>(),
        ));
    gh.lazySingleton<_i427.BootstrapCubit>(
        () => _i427.BootstrapCubit(gh<_i373.LocalService>()));
    gh.factoryParam<_i131.VerifyCodeCubit, String, dynamic>((
      email,
      _,
    ) =>
        _i131.VerifyCodeCubit(
          email,
          gh<_i432.AuthenticationService>(),
        ));
    return this;
  }
}

class _$InjectableModule extends _i920.InjectableModule {}

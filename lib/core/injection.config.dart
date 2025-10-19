// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../cubit/location_cubit.dart' as _i502;
import '../cubit/map_cubit.dart' as _i438;
import '../services/location_service.dart' as _i669;
import '../services/storage_service.dart' as _i306;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i669.LocationService>(() => _i669.LocationService());
    gh.lazySingleton<_i306.StorageService>(() => _i306.StorageService());
    gh.singleton<_i438.MapCubit>(
      () => _i438.MapCubit(
        gh<_i306.StorageService>(),
        gh<_i669.LocationService>(),
      ),
    );
    gh.singleton<_i502.LocationCubit>(
      () => _i502.LocationCubit(
        gh<_i669.LocationService>(),
        gh<_i306.StorageService>(),
      ),
    );
    return this;
  }
}

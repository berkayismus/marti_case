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

import '../../cubit/location_cubit.dart' as _i811;
import '../../cubit/map_cubit.dart' as _i840;
import '../../services/location_service.dart' as _i537;
import '../../services/storage_service.dart' as _i389;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i537.LocationService>(() => _i537.LocationService());
    gh.lazySingleton<_i389.StorageService>(() => _i389.StorageService());
    gh.singleton<_i840.MapCubit>(
      () => _i840.MapCubit(
        gh<_i389.StorageService>(),
        gh<_i537.LocationService>(),
      ),
    );
    gh.singleton<_i811.LocationCubit>(
      () => _i811.LocationCubit(
        gh<_i537.LocationService>(),
        gh<_i389.StorageService>(),
      ),
    );
    return this;
  }
}

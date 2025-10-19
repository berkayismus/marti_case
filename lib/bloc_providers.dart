import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marti_case/core/injection.dart';
import 'package:marti_case/cubit/location_cubit.dart';
import 'package:marti_case/cubit/map_cubit.dart';

class BlocProviders extends StatelessWidget {
  const BlocProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final locationCubit = getIt<LocationCubit>();
    final mapCubit = getIt<MapCubit>();
    
    // Connect LocationCubit to MapCubit
    locationCubit.onMarkersUpdated = (markers) {
      mapCubit.updateMarkers(markers);
    };

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => locationCubit..initialize(),
        ),
        BlocProvider(
          create: (context) => mapCubit,
        ),
      ],
      child: child,
    );
  }
}

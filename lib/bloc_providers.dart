import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marti_case/core/injection.dart';
import 'package:marti_case/cubit/location_cubit.dart';

class BlocProviders extends StatelessWidget {
  const BlocProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<LocationCubit>()..initialize()),
      ],
      child: child,
    );
  }
}

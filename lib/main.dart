import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marti_case/core/app_theme.dart';

import 'cubit/location_cubit.dart';
import 'screens/map_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marti Case - Konum Takibi',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.theme,
      home: BlocProvider(
        create: (context) => LocationCubit()..initialize(),
        child: const MapScreen(),
      ),
    );
  }
}

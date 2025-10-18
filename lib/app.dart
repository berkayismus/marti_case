import 'package:flutter/material.dart';
import 'package:marti_case/bloc_providers.dart';
import 'package:marti_case/core/app_theme.dart';
import 'package:marti_case/screens/map_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marti Case - Konum Takibi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: BlocProviders(child: const MapScreen()),
    );
  }
}

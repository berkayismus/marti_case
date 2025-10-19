import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData theme = ThemeData(
    primarySwatch: Colors.green,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
  );
}

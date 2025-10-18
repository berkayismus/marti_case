import 'package:flutter/material.dart';
import 'package:marti_case/app.dart';
import 'package:marti_case/core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

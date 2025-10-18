import 'package:flutter/material.dart';
import 'package:marti_case/app.dart';
import 'package:marti_case/core/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}

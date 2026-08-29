// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home_page.dart';

/// The entry point of the "Weather Companion" Flutter application.
void main() {
  runApp(const WeatherCompanionApp());
}

/// WeatherCompanionApp configures global application settings,
/// MaterialApp title, and sets HomePage as the initial screen.
class WeatherCompanionApp extends StatelessWidget {
  const WeatherCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0914),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

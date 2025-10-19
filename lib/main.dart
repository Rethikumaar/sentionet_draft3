import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(SentioNetApp());
}

class SentioNetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SentioNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigoAccent,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

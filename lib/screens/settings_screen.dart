import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: const Center(child: Text("App preferences will be here")),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }
}

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/test_screen.dart';
import '../screens/result_screen.dart';
import '../screens/settings_screen.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            break;
          case 1:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const TestScreen()));
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ResultScreen(apiResponse: {}),
              ),
            );
            break;

          case 3:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.quiz), label: 'Test'),
        NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Results'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

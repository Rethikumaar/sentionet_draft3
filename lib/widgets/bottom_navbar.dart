import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/features_screen.dart';
import '../screens/pricing_screen.dart';
import '../screens/testimonials_screen.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 70,
      backgroundColor: Colors.white,
      indicatorColor: Colors.indigo.withOpacity(0.2),
      elevation: 3,
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return; // Prevent reloading same page

        Widget nextScreen;
        switch (index) {
          case 0:
            nextScreen = const HomeScreen();
            break;
          case 1:
            nextScreen = const FeaturesScreen();
            break;
          case 2:
            nextScreen = const PricingScreen();
            break;
          case 3:
            nextScreen = const TestimonialScreen();
            break;
          default:
            nextScreen = const HomeScreen();
        }

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => nextScreen,
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: Colors.indigo),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_border),
          selectedIcon: Icon(Icons.star, color: Colors.indigo),
          label: 'Features',
        ),
        NavigationDestination(
          icon: Icon(Icons.attach_money_outlined),
          selectedIcon: Icon(Icons.attach_money, color: Colors.indigo),
          label: 'Pricing',
        ),
        NavigationDestination(
          icon: Icon(Icons.reviews_outlined),
          selectedIcon: Icon(Icons.reviews, color: Colors.indigo),
          label: 'Testimonials',
        ),
      ],
    );
  }
}

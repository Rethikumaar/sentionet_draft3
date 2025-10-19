import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false; // 🔐 Change this after Firebase setup

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32, errorBuilder: (_, __, ___) {
              return const Icon(Icons.psychology_alt, color: Colors.indigoAccent);
            }),
            const SizedBox(width: 8),
            const Text('SentioNet'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isLoggedIn ? Icons.person : Icons.login),
            onPressed: () {
              if (isLoggedIn) {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ProfileScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login feature coming soon!")),
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Hi there 👋\nHow are you feeling today?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }
}

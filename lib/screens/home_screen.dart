import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() => currentUser = user);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png',
                height: 32,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.psychology_alt, color: Colors.white)),
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
                    context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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

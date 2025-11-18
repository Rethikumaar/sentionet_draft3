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
    String username =
        currentUser?.email?.split('@').first ?? "Guest";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.indigoAccent,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.psychology_alt, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'SentioNet',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isLoggedIn ? Icons.person : Icons.login, color: Colors.white),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section
            Text(
              "Hi, $username 👋",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 25),

            // Hero section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFDEE9FF), Color(0xFFE3F2FD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Track Your Mind,",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        Text(
                          "Understand Your Emotions 💭",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/mental_health.png',
                    height: 100,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.health_and_safety,
                        size: 70, color: Colors.indigo),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Action Cards
            const Text(
              "Quick Actions",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionCard(
                  icon: Icons.analytics_outlined,
                  title: "Start Test",
                  color: Colors.indigoAccent,
                  onTap: () => Navigator.pushNamed(context, '/test'),
                ),
                _buildActionCard(
                  icon: Icons.history,
                  title: "Past Results",
                  color: Colors.blueAccent,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Past Results coming soon")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionCard(
                  icon: Icons.show_chart,
                  title: "Mood Trends",
                  color: Colors.deepPurpleAccent,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mood Trends coming soon")),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.settings,
                  title: "Settings",
                  color: Colors.teal,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Settings coming soon")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Motivational Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "💡 Remember: It's okay to not be okay. Taking a moment to understand your emotions is the first step toward healing.",
                style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}

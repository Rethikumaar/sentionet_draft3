import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sentionet_draft3/screens/test_screen.dart';
import '../widgets/bottom_navbar.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  User? currentUser;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() => currentUser = user);
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    bool isLoggedIn = currentUser != null;
    String username = currentUser?.email?.split('@').first ?? "Guest";

    // Calculate responsive padding
    double horizontalPadding = isDesktop ? 40 : (isTablet ? 30 : 20);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigoAccent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigoAccent,
                Colors.indigo.shade700,
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/logo.png',
                height: 28,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.psychology_alt, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SentioNet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLoggedIn ? Icons.person : Icons.login,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                if (isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isDesktop ? 30 : 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting section
                  _buildGreetingSection(username, isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 35 : 25),

                  // Hero section
                  _buildHeroSection(isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 40 : 30),

                  // Action Cards
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : 15),
                  _buildActionCards(context, isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 40 : 30),

                  // Motivational Section
                  _buildMotivationalSection(isDesktop, isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildGreetingSection(String username, bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi, $username 👋",
          style: TextStyle(
            fontSize: isDesktop ? 36 : (isTablet ? 30 : 26),
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "How are you feeling today?",
          style: TextStyle(
            fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(bool isDesktop, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade400,
            Colors.purple.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Track Your Mind,",
                  style: TextStyle(
                    fontSize: isDesktop ? 26 : (isTablet ? 22 : 20),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Understand Your Emotions 💭",
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isDesktop ? 20 : 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TestScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 24,
                      vertical: isDesktop ? 16 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isTablet && !isDesktop) const SizedBox(width: 16),
          Image.asset(
            'assets/mental_health.png',
            height: isDesktop ? 140 : (isTablet ? 120 : 100),
            errorBuilder: (_, __, ___) => Icon(
              Icons.health_and_safety,
              size: isDesktop ? 100 : (isTablet ? 85 : 70),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context, bool isDesktop, bool isTablet) {
    final actions = [
      ActionCardData(
        icon: Icons.analytics_outlined,
        title: "Start Test",
        color: Colors.indigoAccent,
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TestScreen()),
          );
        },
      ),
      ActionCardData(
        icon: Icons.history,
        title: "Past Results",
        color: Colors.blueAccent,
        gradient: const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Past Results coming soon")),
          );
        },
      ),
      ActionCardData(
        icon: Icons.show_chart,
        title: "Mood Trends",
        color: Colors.deepPurpleAccent,
        gradient: const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mood Trends coming soon")),
          );
        },
      ),
      ActionCardData(
        icon: Icons.settings,
        title: "Settings",
        color: Colors.teal,
        gradient: const LinearGradient(
          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Settings coming soon")),
          );
        },
      ),
    ];

    if (isDesktop || isTablet) {
      // Grid layout for larger screens
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return _buildActionCard(
            action: actions[index],
            isLarge: isDesktop || isTablet,
          );
        },
      );
    } else {
      // 2x2 layout for mobile
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(action: actions[0], isLarge: false),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(action: actions[1], isLarge: false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(action: actions[2], isLarge: false),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(action: actions[3], isLarge: false),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildActionCard({
    required ActionCardData action,
    required bool isLarge,
  }) {
    return _AnimatedActionCard(
      action: action,
      isLarge: isLarge,
    );
  }

  Widget _buildMotivationalSection(bool isDesktop, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : (isTablet ? 24 : 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade50,
            Colors.purple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.indigo.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: Colors.indigo.shade700,
              size: isDesktop ? 32 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Remember: It's okay to not be okay. Taking a moment to understand your emotions is the first step toward healing.",
              style: TextStyle(
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                color: Colors.black87,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionCardData {
  final IconData icon;
  final String title;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  ActionCardData({
    required this.icon,
    required this.title,
    required this.color,
    required this.gradient,
    required this.onTap,
  });
}

class _AnimatedActionCard extends StatefulWidget {
  final ActionCardData action;
  final bool isLarge;

  const _AnimatedActionCard({
    required this.action,
    required this.isLarge,
  });

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.action.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: widget.isLarge ? null : 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  widget.action.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.action.color.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.action.color.withOpacity(_isPressed ? 0.3 : 0.15),
                  blurRadius: _isPressed ? 12 : 8,
                  offset: Offset(0, _isPressed ? 6 : 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(widget.isLarge ? 16 : 14),
                  decoration: BoxDecoration(
                    gradient: widget.action.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.action.color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.action.icon,
                    color: Colors.white,
                    size: widget.isLarge ? 32 : 28,
                  ),
                ),
                SizedBox(height: widget.isLarge ? 14 : 12),
                Text(
                  widget.action.title,
                  style: TextStyle(
                    color: widget.action.color.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isLarge ? 16 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
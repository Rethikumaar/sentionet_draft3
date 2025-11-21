import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    // Calculate cross axis count based on screen size
    int crossAxisCount = 2;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Features",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigoAccent,
                    Colors.indigoAccent.withOpacity(0.1),
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: isDesktop ? 40 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Discover Our Capabilities",
                    style: TextStyle(
                      fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "AI-powered mental health analysis at your fingertips",
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Features Grid
            Padding(
              padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 24 : 20)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isDesktop ? 24 : 16,
                    mainAxisSpacing: isDesktop ? 24 : 16,
                    childAspectRatio: isDesktop ? 1.1 : (isTablet ? 1.0 : 0.95),
                    children: const [
                      FeatureCard(
                        icon: Icons.psychology_alt,
                        title: "Emotion Detection",
                        description:
                        "AI-powered analysis using text, PHQ-10 and face emotion.",
                        gradient: LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                      ),
                      FeatureCard(
                        icon: Icons.face_6,
                        title: "Facial Analysis",
                        description:
                        "Deep learning models interpret facial expressions.",
                        gradient: LinearGradient(
                          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        ),
                      ),
                      FeatureCard(
                        icon: Icons.health_and_safety,
                        title: "Mental Health Tools",
                        description:
                        "Includes PHQ-10 clinically validated questionnaires.",
                        gradient: LinearGradient(
                          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                        ),
                      ),
                      FeatureCard(
                        icon: Icons.auto_graph,
                        title: "Mood Trends",
                        description:
                        "Visual graphs track emotional progress over time.",
                        gradient: LinearGradient(
                          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
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
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: () {
          // Add navigation or action here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.title} tapped'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: _isHovered ? 12 : 4,
            shadowColor: Colors.indigo.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.indigo.shade50.withOpacity(0.3),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gradient Icon Container
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 16 : 12),
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: isDesktop ? 36 : (isTablet ? 32 : 28),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 16 : 12),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 12 : 8),
                    Flexible(
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
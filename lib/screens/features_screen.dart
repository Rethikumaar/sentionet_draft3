import 'package:flutter/material.dart';

import '../widgets/bottom_navbar.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Features"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            FeatureCard(
              icon: Icons.psychology_alt,
              title: "Emotion Detection",
              description:
              "AI-powered analysis using text, PHQ-10 and face emotion.",
            ),
            FeatureCard(
              icon: Icons.face_6,
              title: "Facial Analysis",
              description:
              "Deep learning models interpret facial expressions.",
            ),
            FeatureCard(
              icon: Icons.health_and_safety,
              title: "Mental Health Tools",
              description:
              "Includes PHQ-10 clinically validated questionnaires.",
            ),
            FeatureCard(
              icon: Icons.auto_graph,
              title: "Mood Trends",
              description:
              "Visual graphs track emotional progress over time.",
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.indigoAccent),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

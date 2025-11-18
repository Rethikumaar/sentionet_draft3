import 'package:flutter/material.dart';

import '../widgets/bottom_navbar.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Pricing"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            SizedBox(height: 20),
            PricingCard(
              title: "Basic",
              price: "Free",
              features: [
                "PHQ-10 assessment",
                "Text emotion analysis",
                "Basic mood tracking",
              ],
            ),
            SizedBox(height: 20),
            PricingCard(
              title: "Premium",
              price: "₹299/month",
              features: [
                "Full AI emotion fusion",
                "Facial expression model",
                "Advanced mood trends",
                "Report export",
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}

class PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;

  const PricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ...features.map(
                  (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
              Text("Choose $title", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../widgets/bottom_navbar.dart';

class TestimonialScreen extends StatelessWidget {
  const TestimonialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Testimonials"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          TestimonialCard(
            quote:
            "This platform transformed how I support my patients. Emotion fusion is incredibly accurate!",
            name: "Dr. Sarah Johnson",
            title: "Clinical Psychologist",
          ),
          SizedBox(height: 20),
          TestimonialCard(
            quote:
            "The PHQ-10 integration and mood trends helped patients understand their mental state much better.",
            name: "Dr. Michael Chen",
            title: "Psychiatrist",
          ),
          SizedBox(height: 20),
          TestimonialCard(
            quote:
            "A powerful tool! Perfect blend of AI and mental health expertise.",
            name: "Dr. Anita Kapoor",
            title: "Counseling Therapist",
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String quote;
  final String name;
  final String title;

  const TestimonialCard({
    super.key,
    required this.quote,
    required this.name,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"$quote"',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

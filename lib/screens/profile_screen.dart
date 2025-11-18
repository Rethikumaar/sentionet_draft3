// lib/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildTests(),
          const SizedBox(height: 20),
          _buildAppointmentButton(),
        ],
      ),
    );
  }

  // ---------------- PROFILE HEADER ----------------
  Widget _buildHeader() {
    final email = user?.email ?? "Unknown";
    final name = email.split("@").first;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.indigoAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.indigo),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
              Text(email, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- RECENT TESTS ----------------
  Widget _buildTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Assessments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .collection("responses")
              .orderBy("timestamp", descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Text("No assessments yet.");
            }

            return Column(
              children: docs.map((d) {
                final data = d["api_result"];
                final fusion = data["fusion_result"];
                final score = ((fusion["final_score"] ?? 0.0) * 100).toStringAsFixed(1);
                final risk = fusion["risk_level"];

                return Card(
                  child: ListTile(
                    title: Text("Score: $score%"),
                    subtitle: Text("Risk Level: $risk"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ---------------- APPOINTMENT BUTTON ----------------

  Widget _buildAppointmentButton() {
    return ElevatedButton.icon(
      onPressed: _openAppointmentDialog,
      icon: const Icon(Icons.calendar_today),
      label: const Text("Book Appointment"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ---------------- APPOINTMENT POPUP ----------------

  void _openAppointmentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => _buildDoctorSheet(),
    );
  }

  Widget _buildDoctorSheet() {
    final List<Map<String, String>> doctors = [
      {
        "name": "Dr. Maya Srinivasan",
        "speciality": "Clinical Psychologist",
      },
      {
        "name": "Dr. Arjun Patel",
        "speciality": "Mental Health Specialist",
      },
      {
        "name": "Dr. Leena Thomas",
        "speciality": "Cognitive Therapist",
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Choose a Doctor",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          ...doctors.map((d) {
            return Card(
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(d["name"]!),
                subtitle: Text(d["speciality"]!),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmAppointment(d["name"]!);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: const Text("Select"),
                ),
              ),
            );
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ---------------- CONFIRMATION POPUP ----------------

  void _confirmAppointment(String doctor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Appointment Confirmed"),
        content: Text("Your appointment with $doctor has been booked."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.indigo)),
          )
        ],
      ),
    );
  }
}

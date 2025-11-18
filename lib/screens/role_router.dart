import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'doctor_dashboard.dart';
import 'login_screen.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  Future<Widget> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!snap.exists) {
      return const LoginScreen();
    }

    final role = snap["role"];

    if (role == "Doctor") {
      return const DoctorDashboard();
    } else {
      return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}

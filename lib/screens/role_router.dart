import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'doctor_dashboard.dart';
import 'login_screen.dart';

class RoleRouter extends StatefulWidget {
  const RoleRouter({super.key});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _navigateToLogin();
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (!snap.exists) {
        _navigateToLogin();
        return;
      }

      final role = snap.data()?["role"];

      if (role == "Doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error loading user data: $e";
        });
      }
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigoAccent.withOpacity(0.1),
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade400,
                      Colors.purple.shade400,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology_alt,
                  size: isDesktop ? 80 : (isTablet ? 70 : 60),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isDesktop ? 40 : 32),

              // App Name
              Text(
                'SentioNet',
                style: TextStyle(
                  fontSize: isDesktop ? 42 : (isTablet ? 36 : 32),
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 12),

              // Loading or Error
              if (_isLoading) ...[
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  color: Colors.indigo,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading your profile...',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 40),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 100 : (isTablet ? 80 : 40),
                  ),
                  padding: EdgeInsets.all(isDesktop ? 24 : 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: isDesktop ? 48 : 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
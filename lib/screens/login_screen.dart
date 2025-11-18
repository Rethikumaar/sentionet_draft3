import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';
import 'role_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loadingEmail = false;
  bool _loadingGoogle = false;

  // ---------------- VALIDATE INPUTS ----------------
  bool _validateInputs() {
    if (_emailCtrl.text.trim().isEmpty) {
      _showMsg("Email cannot be empty");
      return false;
    }
    if (!_emailCtrl.text.contains("@")) {
      _showMsg("Enter a valid email");
      return false;
    }
    if (_pwdCtrl.text.trim().isEmpty) {
      _showMsg("Password cannot be empty");
      return false;
    }
    return true;
  }

  // ---------------- EMAIL LOGIN ----------------
  Future<void> _signInEmail() async {
    if (!_validateInputs()) return;

    setState(() => _loadingEmail = true);

    try {
      await _auth.signInWithEmail(
        _emailCtrl.text.trim(),
        _pwdCtrl.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleRouter()),
      );
    } on FirebaseAuthException catch (e) {
      _showMsg(e.message ?? 'Login failed');
    } finally {
      if (mounted) setState(() => _loadingEmail = false);
    }
  }

  // ---------------- GOOGLE LOGIN ----------------
  Future<void> _signInGoogle() async {
    setState(() => _loadingGoogle = true);

    try {
      final cred = await _auth.signInWithGoogle();
      if (cred == null) {
        _showMsg("Google sign-in cancelled");
        return;
      }

      final user = cred.user;
      if (user == null) {
        _showMsg("Google sign-in failed");
        return;
      }

      // Check if user exists in Firestore
      final userDoc = FirebaseFirestore.instance.collection("users").doc(user.uid);
      final snap = await userDoc.get();

      if (!snap.exists) {
        // First-time Google user -> create user record
        await userDoc.set({
          "email": user.email,
          "name": user.displayName,
          "role": "individual",  // <-- default role (change if needed)
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleRouter()),
      );
    } catch (e) {
      _showMsg("Google sign-in failed: $e");
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  // ---------------- SNACKBAR ----------------
  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = _loadingEmail || _loadingGoogle;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _pwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),

            // EMAIL LOGIN BUTTON
            ElevatedButton(
              onPressed: _loadingEmail ? null : _signInEmail,
              child: _loadingEmail
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Login'),
            ),

            const SizedBox(height: 12),

            // GOOGLE LOGIN BUTTON
            ElevatedButton.icon(
              onPressed: _loadingGoogle ? null : _signInGoogle,
              icon: _loadingGoogle
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Image.asset(
                'assets/google_logo.png',
                height: 18,
                width: 18,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.login, color: Colors.black),
              ),
              label: Text(_loadingGoogle ? "Signing in..." : "Sign in with Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: loading
                  ? null
                  : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text("Create new account"),
            ),
          ],
        ),
      ),
    );
  }
}

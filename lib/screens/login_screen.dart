import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'role_router.dart';   // ⬅ IMPORTANT

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;

  // ---------------- EMAIL LOGIN ----------------
  Future<void> _signInEmail() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithEmail(
        _emailCtrl.text.trim(),
        _pwdCtrl.text.trim(),
      );

      if (!mounted) return;

      // ⬅ REDIRECT BASED ON ROLE
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleRouter()),
      );

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---------------- GOOGLE LOGIN ----------------
  Future<void> _signInGoogle() async {
    setState(() => _loading = true);

    try {
      final cred = await _auth.signInWithGoogle();

      if (cred != null && mounted) {
        // ⬅ GOOGLE USERS ALSO GO THROUGH ROLE ROUTER
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleRouter()),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            ElevatedButton(
              onPressed: _loading ? null : _signInEmail,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: Image.asset(
                'assets/google_logo.png',
                height: 18,
                width: 18,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.login, color: Colors.black),
              ),
              label: const Text('Sign in with Google'),
              onPressed: _loading ? null : _signInGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.push(
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

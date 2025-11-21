import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String selectedRole = "Rehabilitant";
  bool _loading = false;
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ---------------- Register ----------------
  Future<void> _register() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      _showMsg("All fields are required");
      return;
    }

    if (!_emailController.text.contains("@")) {
      _showMsg("Please enter a valid email");
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      _showMsg("Password must be at least 6 characters");
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential userCred =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCred.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "role": selectedRole,
          "created_at": DateTime.now(),
          "profile_pic": null,
        });
      }

      if (!mounted) return;

      _showMsg("Account created successfully!");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showMsg(e.message ?? "Registration failed");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.indigo.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.indigo,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              "Creating your account...",
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 32 : 24),
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 500 : (isTablet ? 450 : double.infinity),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon Section
                        _buildIconSection(isDesktop, isTablet),
                        SizedBox(height: isDesktop ? 40 : 32),

                        // Registration Card
                        Card(
                          elevation: 8,
                          shadowColor: Colors.indigo.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(
                              isDesktop ? 40 : (isTablet ? 32 : 24),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.indigo.shade50.withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title
                                Text(
                                  'Join SentioNet',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start your mental wellness journey today',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isDesktop ? 36 : 28),

                                // Full Name Field
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline,
                                  isDesktop: isDesktop,
                                  isTablet: isTablet,
                                ),
                                SizedBox(height: isDesktop ? 20 : 16),

                                // Email Field
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  isDesktop: isDesktop,
                                  isTablet: isTablet,
                                ),
                                SizedBox(height: isDesktop ? 20 : 16),

                                // Password Field
                                _buildPasswordField(isDesktop, isTablet),
                                SizedBox(height: isDesktop ? 20 : 16),

                                // Role Selector
                                _buildRoleDropdown(isDesktop, isTablet),
                                SizedBox(height: isDesktop ? 32 : 24),

                                // Register Button
                                _buildRegisterButton(isDesktop, isTablet),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 24 : 20),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.indigo.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 16 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 20),
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
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.person_add_alt_1,
            size: isDesktop ? 56 : (isTablet ? 48 : 40),
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: isDesktop ? 16 : 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isDesktop ? 16 : 14,
          ),
          prefixIcon: Icon(icon, color: Colors.indigo.shade400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(bool isDesktop, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(fontSize: isDesktop ? 16 : 14),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isDesktop ? 16 : 14,
          ),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.indigo.shade400),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(bool isDesktop, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        style: TextStyle(
          fontSize: isDesktop ? 16 : 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: 'Select Role',
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isDesktop ? 16 : 14,
          ),
          prefixIcon: Icon(Icons.badge_outlined, color: Colors.indigo.shade400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 20 : 16,
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: "Rehabilitant",
            child: Text("Rehabilitant"),
          ),
          DropdownMenuItem(
            value: "Doctor",
            child: Text("Doctor"),
          ),
        ],
        onChanged: (value) => setState(() => selectedRole = value!),
      ),
    );
  }

  Widget _buildRegisterButton(bool isDesktop, bool isTablet) {
    return Container(
      height: isDesktop ? 56 : (isTablet ? 52 : 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade400,
            Colors.indigo.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Create Account',
          style: TextStyle(
            fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
// lib/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sentionet_draft3/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
          "My Profile",
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
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: Colors.white),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1000 : double.infinity,
              ),
              child: Column(
                children: [
                  _buildHeader(isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildStatsCards(isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildTests(isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildAppointmentButton(isDesktop, isTablet),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- PROFILE HEADER ----------------
  Widget _buildHeader(bool isDesktop, bool isTablet) {
    final email = user?.email ?? "Unknown";
    final name = email.split("@").first;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade400,
            Colors.purple.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 6 : 4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: isDesktop ? 45 : (isTablet ? 40 : 35),
              backgroundColor: Colors.indigo.shade100,
              child: Icon(
                Icons.person,
                size: isDesktop ? 48 : (isTablet ? 44 : 40),
                color: Colors.indigo.shade700,
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 24 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : (isTablet ? 24 : 22),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: isDesktop ? 18 : 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Verified Account",
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- STATS CARDS ----------------
  Widget _buildStatsCards(bool isDesktop, bool isTablet) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("responses")
          .snapshots(),
      builder: (context, snapshot) {
        final totalTests = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return isDesktop || isTablet
            ? Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.assessment,
                title: "Total Tests",
                value: "$totalTests",
                color: Colors.blue,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: "This Month",
                value: "3",
                color: Colors.green,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_emotions,
                title: "Avg. Score",
                value: "72%",
                color: Colors.orange,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
            ),
          ],
        )
            : Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.assessment,
                    title: "Total Tests",
                    value: "$totalTests",
                    color: Colors.blue,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_up,
                    title: "This Month",
                    value: "3",
                    color: Colors.green,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              icon: Icons.emoji_emotions,
              title: "Average Score",
              value: "72%",
              color: Colors.orange,
              isDesktop: isDesktop,
              isTablet: isTablet,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 14 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isDesktop ? 32 : (isTablet ? 28 : 24),
            ),
          ),
          SizedBox(height: isDesktop ? 14 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 28 : (isTablet ? 24 : 22),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------- RECENT TESTS ----------------
  Widget _buildTests(bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 28 : (isTablet ? 24 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history,
                  color: Colors.white,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Recent Assessments",
                style: TextStyle(
                  fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 20),

          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user!.uid)
                .collection("responses")
                .orderBy("timestamp", descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.indigo),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(isDesktop ? 40 : 32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: isDesktop ? 64 : 56,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No assessments yet",
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start your first assessment to see results here",
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: docs.map((d) {
                  final data = d["api_result"];
                  final fusion = data["fusion_result"];
                  final score = ((fusion["final_score"] ?? 0.0) * 100).toStringAsFixed(1);
                  final risk = fusion["risk_level"];

                  final timestamp = (d["timestamp"] as Timestamp?)?.toDate();
                  final dateStr = timestamp != null
                      ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
                      : "Unknown date";

                  final color = risk == "High"
                      ? Colors.red
                      : risk == "Moderate"
                      ? Colors.orange
                      : Colors.green;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
                    decoration: BoxDecoration(
                      border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 14 : 12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.analytics_outlined,
                            color: color,
                            size: isDesktop ? 28 : 24,
                          ),
                        ),
                        SizedBox(width: isDesktop ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Score: $score%",
                                style: TextStyle(
                                  fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "$risk Risk",
                                      style: TextStyle(
                                        fontSize: isDesktop ? 13 : 12,
                                        fontWeight: FontWeight.w600,
                                        color: color.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 14 : 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: isDesktop ? 20 : 18,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- APPOINTMENT BUTTON ----------------
  Widget _buildAppointmentButton(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        Container(
          width: double.infinity,
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
          child: ElevatedButton.icon(
            onPressed: _openAppointmentDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            label: Text(
              "Book Appointment with Doctor",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Container(
          width: double.infinity,
          height: isDesktop ? 56 : (isTablet ? 52 : 48),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade400, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout,
                          color: Colors.red.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Logout",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(fontSize: 15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );

              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade700,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(Icons.logout, color: Colors.red.shade700),
            label: Text(
              "Logout",
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- APPOINTMENT POPUP ----------------
  void _openAppointmentDialog() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: _buildDoctorSheet(isDesktop, isTablet),
      ),
    );
  }

  Widget _buildDoctorSheet(bool isDesktop, bool isTablet) {
    final List<Map<String, String>> doctors = [
      {
        "name": "Dr. Maya Srinivasan",
        "speciality": "Clinical Psychologist",
        "experience": "15 years",
      },
      {
        "name": "Dr. Arjun Patel",
        "speciality": "Mental Health Specialist",
        "experience": "12 years",
      },
      {
        "name": "Dr. Leena Thomas",
        "speciality": "Cognitive Therapist",
        "experience": "10 years",
      },
    ];

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: isDesktop ? 28 : 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  color: Colors.white,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Choose a Doctor",
                style: TextStyle(
                  fontSize: isDesktop ? 26 : (isTablet ? 24 : 22),
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 28 : 24),

          ...doctors.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 14 : 12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.indigo.shade700,
                      size: isDesktop ? 32 : 28,
                    ),
                  ),
                  SizedBox(width: isDesktop ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d["name"]!,
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d["speciality"]!,
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${d["experience"]} experience",
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 12,
                            color: Colors.indigo.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: isDesktop ? 120 : 90,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmAppointment(d["name"]!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 14 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Select",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 15 : 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: isDesktop ? 20 : 16),
        ],
      ),
    );
  }

  // ---------------- CONFIRMATION POPUP ----------------
  void _confirmAppointment(String doctor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              "Confirmed!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Your appointment with $doctor has been successfully booked.",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
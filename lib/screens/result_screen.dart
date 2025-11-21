// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navbar.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> apiResponse;
  final Map<String, int>? phqAnswers;
  final String? inputText;
  final List<String>? imageUrls;

  const ResultScreen({
    super.key,
    required this.apiResponse,
    this.phqAnswers,
    this.inputText,
    this.imageUrls,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
    _saveResultToFirestore();
  }

  // Save result to Firestore
  Future<void> _saveResultToFirestore() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("responses")
          .add({
        "api_result": widget.apiResponse,
        "phq_answers": widget.phqAnswers,
        "input_text": widget.inputText,
        "image_urls": widget.imageUrls,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving result: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    final fusion = widget.apiResponse["fusion_result"] ?? {};
    final risk = fusion["risk_level"] ?? "Unknown";
    final score = ((fusion["final_score"] ?? 0.0) as num).toDouble() * 100;
    final weights = (fusion["weights"] ?? {}) as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Assessment Results",
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
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo.shade600,
        onPressed: () => Navigator.pushNamed(context, "/home"),
        label: const Text(
          "Back to Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.home),
        elevation: 4,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildRiskCard(risk, score, isDesktop, isTablet),
                  ),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildBarChart(weights, isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildRecommendations(risk, score, isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildSummarySection(isDesktop, isTablet),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiskCard(String risk, double score, bool isDesktop, bool isTablet) {
    final baseColor = _getRiskColor(risk);
    final icon = _getRiskIcon(risk);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 36 : (isTablet ? 32 : 28)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: 0.85),
            baseColor.withValues(alpha: 1.00),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isDesktop ? 56 : (isTablet ? 48 : 40),
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          Text(
            "$risk Risk Level",
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 20,
              vertical: isDesktop ? 12 : 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Score: ${score.toStringAsFixed(1)}%",
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          Container(
            height: isDesktop ? 12 : 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case "high":
        return Colors.red;
      case "moderate":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case "high":
        return Icons.warning_rounded;
      case "moderate":
        return Icons.info_rounded;
      case "low":
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildBarChart(Map<String, dynamic> weights, bool isDesktop, bool isTablet) {
    if (weights.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isDesktop ? 40 : 32),
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
        child: const Center(
          child: Text(
            "No modality data available",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final entries = weights.entries.toList();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
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
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Modality Contribution",
                style: TextStyle(
                  fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "How each assessment type contributed to your results",
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isDesktop ? 32 : 24),
          AspectRatio(
            aspectRatio: isDesktop ? 2.2 : (isTablet ? 2.0 : 1.5),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barGroups: List.generate(entries.length, (i) {
                  final y = (entries[i].value as num).toDouble() * 100;
                  final color = _getModalityColor(i);

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: y,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            color.withValues(alpha: 0.7),
                            color,
                          ],
                        ),
                        width: isDesktop ? 40 : (isTablet ? 32 : 24),
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: Colors.grey.shade200,
                        ),
                      )
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        int index = value.toInt();
                        if (index >= 0 && index < entries.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entries[index].key,
                              style: TextStyle(
                                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                                fontWeight: FontWeight.w600,
                                color: _getModalityColor(index),
                              ),
                            ),
                          );
                        }
                        return const Text("");
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) {
                        return Text(
                          "${value.toInt()}%",
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 12,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getModalityColor(int index) {
    final colors = [
      Colors.indigo.shade700,
      Colors.purple.shade600,
      Colors.blue.shade600,
      Colors.teal.shade600,
    ];
    return colors[index % colors.length];
  }

  Widget _buildRecommendations(String risk, double score, bool isDesktop, bool isTablet) {
    final recommendations = _getRecommendations(risk, score);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
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
                    colors: [Colors.green.shade400, Colors.teal.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Recommendations",
                style: TextStyle(
                  fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rec,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getRecommendations(String risk, double score) {
    if (risk.toLowerCase() == "high" || score > 70) {
      return [
        "Consider scheduling an appointment with a mental health professional",
        "Practice daily mindfulness or meditation for 10-15 minutes",
        "Maintain a regular sleep schedule and aim for 7-9 hours",
        "Engage in physical activity at least 30 minutes daily",
        "Connect with supportive friends or family members",
      ];
    } else if (risk.toLowerCase() == "moderate" || score > 40) {
      return [
        "Monitor your mental health and take note of any changes",
        "Practice stress-reduction techniques like deep breathing",
        "Maintain social connections and engage in enjoyable activities",
        "Ensure adequate sleep and balanced nutrition",
        "Consider journaling to process your thoughts and feelings",
      ];
    } else {
      return [
        "Continue your current healthy habits and routines",
        "Stay connected with your support network",
        "Maintain regular physical activity and good sleep hygiene",
        "Practice gratitude and positive thinking",
        "Be aware of your mental health and check in with yourself regularly",
      ];
    }
  }

  Widget _buildSummarySection(bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
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
                    colors: [Colors.blue.shade400, Colors.cyan.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Input Summary",
                style: TextStyle(
                  fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 20),

          if (widget.phqAnswers != null) ...[
            _buildSummaryCard(
              icon: Icons.psychology_outlined,
              title: "PHQ-10 Assessment",
              subtitle: "Completed ${widget.phqAnswers!.length} questions",
              color: Colors.indigo,
              isDesktop: isDesktop,
              isTablet: isTablet,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.phqAnswers!.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${e.key}: ${e.value}",
                      style: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop ? 14 : 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (widget.inputText != null && widget.inputText!.isNotEmpty) ...[
            _buildSummaryCard(
              icon: Icons.chat_bubble_outline,
              title: "Text Input",
              subtitle: "${widget.inputText!.length} characters",
              color: Colors.blue,
              isDesktop: isDesktop,
              isTablet: isTablet,
              child: Container(
                padding: EdgeInsets.all(isDesktop ? 16 : 14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.inputText!,
                  style: TextStyle(
                    fontSize: isDesktop ? 15 : 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty)
            _buildSummaryCard(
              icon: Icons.photo_camera,
              title: "Captured Images",
              subtitle: "${widget.imageUrls!.length} image${widget.imageUrls!.length > 1 ? 's' : ''}",
              color: Colors.purple,
              isDesktop: isDesktop,
              isTablet: isTablet,
              child: SizedBox(
                height: isDesktop ? 140 : (isTablet ? 120 : 100),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imageUrls!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.imageUrls![index],
                          width: isDesktop ? 140 : (isTablet ? 120 : 100),
                          height: isDesktop ? 140 : (isTablet ? 120 : 100),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: isDesktop ? 140 : (isTablet ? 120 : 100),
                              height: isDesktop ? 140 : (isTablet ? 120 : 100),
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.indigo,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: isDesktop ? 140 : (isTablet ? 120 : 100),
                              height: isDesktop ? 140 : (isTablet ? 120 : 100),
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.error_outline, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget child,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isDesktop ? 24 : 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 16 : 14),
          child,
        ],
      ),
    );
  }
}
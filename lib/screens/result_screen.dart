// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/bottom_navbar.dart';

class ResultScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final fusion = apiResponse["fusion_result"] ?? {};
    final risk = fusion["risk_level"] ?? "Unknown";

    // FIX: Convert num → double
    final score = ((fusion["final_score"] ?? 0.0) as num).toDouble() * 100;

    final weights = (fusion["weights"] ?? {}) as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Result Overview"),
        backgroundColor: Colors.indigo,
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () => Navigator.pushNamed(context, "/home"),
        label: const Text("Back to Home"),
        icon: const Icon(Icons.home),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRiskCard(risk, score),
          const SizedBox(height: 20),
          _buildBarChart(weights),
          const SizedBox(height: 20),
          _buildSummarySection(),
        ],
      ),
    );
  }

  // ---------------- RISK CARD ----------------

  Widget _buildRiskCard(String risk, double score) {
    final baseColor = risk == "High"
        ? Colors.red
        : risk == "Moderate"
        ? Colors.orange
        : Colors.green;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.70), // FIXED
            baseColor.withValues(alpha: 1.00), // FIXED
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.40), // FIXED
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            risk,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Final Score: ${score.toStringAsFixed(1)}%",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: score / 100,
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  // ---------------- BAR CHART ----------------

  Widget _buildBarChart(Map<String, dynamic> weights) {
    if (weights.isEmpty) {
      return const Text("No modality data");
    }

    final entries = weights.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Modality Contribution",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(entries.length, (i) {
                // FIX: num → double
                final y = (entries[i].value as num).toDouble() * 100;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: y,
                      color: Colors.indigo,
                      width: 20,
                      borderRadius: BorderRadius.circular(6),
                    )
                  ],
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      int index = value.toInt();
                      if (index >= 0 && index < entries.length) {
                        return Text(entries[index].key, style: const TextStyle(fontSize: 12));
                      }
                      return const Text("");
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- SUMMARY ----------------

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Input Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        if (phqAnswers != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.quiz, color: Colors.indigo),
              title: const Text("PHQ-10 Responses"),
              subtitle: Text(phqAnswers.toString()),
            ),
          ),

        if (inputText != null && inputText!.isNotEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.textsms, color: Colors.indigo),
              title: const Text("User Text Input"),
              subtitle: Text(inputText!),
            ),
          ),

        if (imageUrls != null && imageUrls!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Captured Images",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: imageUrls!
                      .map((url) => Padding(
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(url, width: 100, fit: BoxFit.cover),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

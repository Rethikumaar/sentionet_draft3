import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/bottom_navbar.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> apiResponse;

  const ResultScreen({super.key, required this.apiResponse});

  @override
  Widget build(BuildContext context) {
    final fusion = (apiResponse["fusion_result"] ?? {}) as Map<String, dynamic>;
    final details = (apiResponse["details"] ?? {}) as Map<String, dynamic>;

    final risk = fusion["risk_level"] ?? "Unknown";
    final finalScoreNum = fusion["final_score"] ?? 0.0;
    final score = (finalScoreNum is num) ? (finalScoreNum * 100.0) : 0.0;
    final weights = Map<String, dynamic>.from(fusion["weights"] ?? {});
    final modal = Map<String, dynamic>.from(fusion["modalities"] ?? {});

    return Scaffold(
      appBar: AppBar(title: const Text("Result Analysis")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Text(
                "🧩 $risk",
                style:
                const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildProgress("Final Score", (score / 100.0).clamp(0.0, 1.0),
                Colors.indigo),
            const SizedBox(height: 25),
            const Text("🧠 Modality Breakdown",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            weights.isNotEmpty
                ? _buildBarChart(weights)
                : const Text("No modality weights available"),
            const SizedBox(height: 25),
            const Text("🎯 Modality Scores",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (modal.isEmpty)
              const Text("No modality scores available.")
            else
              ...modal.entries.map((e) {
                final v = e.value as Map<String, dynamic>;
                final scorePct =
                ((v['score'] ?? 0.0) is num) ? (v['score'] * 100) : 0.0;
                final confPct =
                ((v['conf'] ?? 0.0) is num) ? (v['conf'] * 100) : 0.0;
                return ListTile(
                  leading: const Icon(Icons.analytics),
                  title: Text(e.key.toUpperCase()),
                  subtitle:
                  Text("Score: ${scorePct.toStringAsFixed(1)}%"),
                  trailing:
                  Text("Conf: ${confPct.toStringAsFixed(1)}%"),
                );
              }),
            const SizedBox(height: 20),
            Text("📝 Input Summary:\n${details["input_text"] ?? "No text"}"),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildProgress(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${(value * 100).toStringAsFixed(1)}%"),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: Colors.grey.shade300,
          minHeight: 12,
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, dynamic> weights) {
    final entries = weights.entries.toList();
    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          maxY: 100,
          barGroups: List.generate(entries.length, (i) {
            final e = entries[i];
            final y = (e.value is num) ? (e.value * 100) : 0.0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: y,
                  color: Colors.indigoAccent,
                  width: 18,
                )
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(entries[idx].key,
                      style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}

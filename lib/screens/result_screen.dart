import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> apiResponse;

  const ResultScreen({super.key, required this.apiResponse});

  @override
  Widget build(BuildContext context) {
    final fusion = apiResponse["fusion_result"] ?? {};
    final details = apiResponse["details"] ?? {};

    final risk = fusion["risk_level"] ?? "Unknown";
    final score = (fusion["final_score"] ?? 0.0) * 100;
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
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildProgress("Final Score", score / 100, Colors.indigo),
            const SizedBox(height: 25),
            const Text("🧠 Modality Breakdown",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildBarChart(weights),
            const SizedBox(height: 25),
            const Text("🎯 Modality Scores",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...modal.entries.map((e) => ListTile(
              leading: const Icon(Icons.analytics),
              title: Text(e.key.toUpperCase()),
              subtitle:
              Text("Score: ${(e.value['score'] * 100).toStringAsFixed(1)}%"),
              trailing: Text(
                  "Conf: ${(e.value['conf'] * 100).toStringAsFixed(1)}%"),
            )),
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
          borderRadius: BorderRadius.circular(8),
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
          barGroups: List.generate(entries.length, (i) {
            final e = entries[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                    toY: (e.value * 100),
                    color: Colors.indigoAccent,
                    width: 18)
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Text(entries[value.toInt()].key);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }
}

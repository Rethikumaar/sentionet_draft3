import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Store PHQ-10 answers (0–3)
  final Map<String, int> _phqAnswers = {
    for (int i = 1; i <= 10; i++) "q$i": 0,
  };

  bool _loading = false;

  // API endpoint
  final String apiUrl = "https://akash297-tepi.hf.space/predict";

  Future<void> _submitAnalysis() async {
    if (_textController.text.isEmpty && _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide at least one input")),
      );
      return;
    }

    setState(() => _loading = true);

    final body = {
      "phq_responses": _phqAnswers,
      "text": _textController.text,
      "images": [_imageUrlController.text],
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(apiResponse: result),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("API Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to API: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Multimodal Test")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🧠 PHQ-10 Questionnaire",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(10, (i) {
              final qNum = i + 1;
              final question = _questions[qNum - 1];
              return _buildQuestion(qNum, question);
            }),
            const SizedBox(height: 25),
            const Text(
              "💬 Text + Emoji Input",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Describe your feelings... 😊😔",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "📷 Image Input",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                hintText: "Enter image URL (optional)",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                suffixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text("Analyze All Inputs"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _submitAnalysis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$number. $text", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) {
              final label = ["0", "1", "2", "3"][i];
              return Row(
                children: [
                  Radio<int>(
                    value: i,
                    groupValue: _phqAnswers["q$number"],
                    onChanged: (val) {
                      setState(() => _phqAnswers["q$number"] = val ?? 0);
                    },
                  ),
                  Text(label),
                ],
              );
            }),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

// ---- PHQ-10 Questions ----
const List<String> _questions = [
  "Little interest or pleasure in doing things",
  "Feeling down, depressed, or hopeless",
  "Trouble falling or staying asleep, or sleeping too much",
  "Feeling tired or having little energy",
  "Poor appetite or overeating",
  "Feeling bad about yourself — or that you are a failure",
  "Trouble concentrating on things",
  "Moving or speaking so slowly or being restless",
  "Thoughts of self-harm or that you’d be better off dead",
  "If you checked any problems, how difficult have these made life for you?",
];

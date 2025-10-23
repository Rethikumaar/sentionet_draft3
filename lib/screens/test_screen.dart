import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_navbar.dart';
import 'result_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  final Map<String, int> _phqAnswers = {
    for (int i = 1; i <= 10; i++) "q$i": 0,
  };

  bool _loading = false;
  final String apiUrl = "https://akash297-tepi.hf.space/predict";

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (photo != null) setState(() => _pickedImage = photo);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error: $e')),
      );
    }
  }

  /// ✅ Upload image to Firebase Storage and get download URL
  Future<String?> _uploadImageAndGetUrl(XFile file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("patient_images/${DateTime.now().millisecondsSinceEpoch}.jpg");
      final uploadTask = await storageRef.putFile(File(file.path));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      return null;
    }
  }

  Future<void> _submitAnalysis() async {
    if (_textController.text.isEmpty && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide text or image")),
      );
      return;
    }

    setState(() => _loading = true);

    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await _uploadImageAndGetUrl(_pickedImage!);
    }

    final body = {
      "phq_responses": _phqAnswers,
      "text": _textController.text.trim(),
      "images": imageUrl != null ? [imageUrl] : [],
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        /// ✅ Save response to Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection("responses")
              .add({
            "timestamp": DateTime.now(),
            "phq_responses": _phqAnswers,
            "text": _textController.text.trim(),
            "image_url": imageUrl,
            "api_result": result,
          });
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ResultScreen(apiResponse: Map<String, dynamic>.from(result)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("API Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Network error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              return Row(
                children: [
                  Radio<int>(
                    value: i,
                    groupValue: _phqAnswers["q$number"],
                    onChanged: (val) {
                      setState(() => _phqAnswers["q$number"] = val ?? 0);
                    },
                  ),
                  Text("$i"),
                ],
              );
            }),
          ),
          const Divider(),
        ],
      ),
    );
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
            const Text("🧠 PHQ-10 Questionnaire",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...List.generate(10, (i) {
              final qNum = i + 1;
              return _buildQuestion(qNum, _questions[i]);
            }),
            const SizedBox(height: 25),
            const Text("💬 Text + Emoji Input",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Describe your feelings... 😊😔",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text("📷 Take a Selfie",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Open Camera"),
                  onPressed: _pickImageFromCamera,
                ),
                const SizedBox(width: 12),
                if (_pickedImage != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_pickedImage!.path),
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
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
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
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

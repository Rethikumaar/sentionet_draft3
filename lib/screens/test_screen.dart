// lib/screens/test_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
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

class _TestScreenState extends State<TestScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool cameraReady = false;

  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: false,
      enableContours: false,
    ),
  );

  String faceStatus = "Position your face";
  Color faceStatusColor = Colors.amber;

  final List<XFile> captured = [];
  final TextEditingController textController = TextEditingController();
  final Map<String, int> phq = {for (int i = 1; i <= 10; i++) "q$i": 0};

  bool loading = false;

  final String apiUrl =
      "https://akash297-tepi.hf.space/predict"; // backend requires URL list!

  late AnimationController pulseController;
  late Animation<double> pulseAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      final front = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
      );

      controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();

      if (!mounted) return;
      setState(() => cameraReady = true);
    } catch (e) {
      showMessage("Camera error: $e");
    }
  }

  Future<void> captureAndDetect() async {
    if (!controller!.value.isInitialized) return;

    setState(() => loading = true);

    try {
      final XFile file = await controller!.takePicture();

      final input = InputImage.fromFilePath(file.path);
      final faces = await faceDetector.processImage(input);

      if (faces.isEmpty) {
        faceStatus = "No face detected";
        faceStatusColor = Colors.red;
        showMessage("No face detected. Try again.");
        File(file.path).delete();
      } else if (faces.length > 1) {
        faceStatus = "Multiple faces";
        faceStatusColor = Colors.red;
        showMessage("Only one face allowed.");
        File(file.path).delete();
      } else {
        faceStatus = "Perfect!";
        faceStatusColor = Colors.green;
        setState(() => captured.insert(0, file));
      }
    } catch (e) {
      showMessage("Capture failed: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<String?> upload(XFile file, int index) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("patient_images/${DateTime.now().millisecondsSinceEpoch}_$index.jpg");

      await storageRef.putFile(File(file.path));
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("UPLOAD ERROR: $e");
      return null;
    }
  }

  Future<void> submit() async {
    if (captured.isEmpty && textController.text.trim().isEmpty) {
      showMessage("Please provide a valid face photo or text.");
      return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      List<String> urls = [];
      for (int i = 0; i < captured.length; i++) {
        final url = await upload(captured[i], i);
        if (url != null) urls.add(url);
      }

      // 🔥 FINAL PAYLOAD → matches the backend doc you uploaded
      final payload = {
        "text": textController.text.trim(),
        "phq_responses": phq,
        "images": urls, // backend requires list of URLs
      };

      print("📤 SENDING PAYLOAD: ${jsonEncode(payload)}");

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("📥 API RESPONSE: ${res.body}");

      if (res.statusCode != 200) {
        showMessage("API error: ${res.statusCode}");
        return;
      }

      final result = jsonDecode(res.body);

      // SAVE INSIDE: users/{uid}/responses/{autoID}
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("responses")
            .add({
          "timestamp": FieldValue.serverTimestamp(),
          "api_result": result,
          "images": urls,
          "text": textController.text.trim(),
          "phq_responses": phq,
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            apiResponse: result,
            phqAnswers: phq,
            inputText: textController.text.trim(),
            imageUrls: urls,
          ),
        ),
      );
    } catch (e) {
      showMessage("Submission error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    pulseController.dispose();
    controller?.dispose();
    faceDetector.close();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Multimodal Assessment"),
        backgroundColor: Colors.indigo,
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      body: !cameraReady
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : buildUI(),
    );
  }

  Widget buildUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ---------------- CAMERA ----------------
          Container(
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: Stack(
                children: [
                  CameraPreview(controller!),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        faceStatus,
                        style: TextStyle(
                          color: faceStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------- CAPTURE BUTTON ----------------
          ScaleTransition(
            scale: pulseAnim,
            child: GestureDetector(
              onTap: loading ? null : captureAndDetect,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                  ),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- PREVIEW IMAGES ----------------
          if (captured.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: captured.length,
                itemBuilder: (_, i) {
                  final f = captured[i];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(f.path),
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => captured.removeAt(i));
                            File(f.path).delete();
                          },
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          const SizedBox(height: 25),

          // ---------------- FORM ----------------
          buildForm(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🧠 PHQ-10 Questionnaire",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          ...List.generate(10, (i) {
            final q = phq.keys.elementAt(i);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text("${i + 1}. ${questions[i]}"),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (score) {
                      return ChoiceChip(
                        selected: phq[q] == score,
                        label: Text(scoreLabels[score]),
                        onSelected: (_) {
                          setState(() {
                            phq[q] = score;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          const Text("💬 Text Input",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          TextField(
            controller: textController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Describe your feelings...",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Center(
            child: ElevatedButton.icon(
              onPressed: loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              icon: const Icon(Icons.analytics, color: Colors.white),
              label: const Text(
                "Analyze Assessment",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------ PHQ QUESTIONS ------------------------

const List<String> questions = [
  "Little interest or pleasure in doing things",
  "Feeling down, depressed, or hopeless",
  "Trouble falling or staying asleep, or sleeping too much",
  "Feeling tired or having little energy",
  "Poor appetite or overeating",
  "Feeling bad about yourself or feeling like a failure",
  "Trouble concentrating",
  "Moving or speaking slowly / restlessness",
  "Thoughts of self-harm",
  "How difficult have these problems made life for you?",
];

const List<String> scoreLabels = [
  "Not at all",
  "Several days",
  "More than half",
  "Nearly every day",
];

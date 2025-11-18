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

class _TestScreenState extends State<TestScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableLandmarks: false,
    ),
  );

  String faceStatus = "Position your face";
  Color faceStatusColor = Colors.amber;

  final List<XFile> _captured = [];
  final TextEditingController _textController = TextEditingController();

  final Map<String, int> _phqAnswers = {
    for (int i = 1; i <= 10; i++) "q$i": 0,
  };

  bool _loading = false;
  final String apiUrl = "https://akash297-tepi.hf.space/predict";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      final front = _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() => _cameraReady = true);
    } catch (e) {
      _showMessage("Camera error: $e");
    }
  }

  Future<void> _captureAndDetect() async {
    if (!_controller!.value.isInitialized) return;

    setState(() => _loading = true);

    try {
      final XFile file = await _controller!.takePicture();

      final image = InputImage.fromFilePath(file.path);
      final faces = await _faceDetector.processImage(image);

      if (faces.isEmpty) {
        faceStatus = "No face detected";
        faceStatusColor = Colors.redAccent;
        _showMessage("No face detected. Try again.");
        await File(file.path).delete();
      } else if (faces.length > 1) {
        faceStatus = "Multiple faces";
        faceStatusColor = Colors.redAccent;
        _showMessage("Only one person should be visible.");
        await File(file.path).delete();
      } else {
        faceStatus = "Perfect!";
        faceStatusColor = Colors.green;
        setState(() => _captured.insert(0, file));
      }
    } catch (e) {
      _showMessage("Failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<String?> _upload(XFile file, int i) async {
    try {
      final ref = FirebaseStorage.instance
          .ref("patient_images/${DateTime.now().millisecondsSinceEpoch}_$i.jpg");

      await ref.putFile(File(file.path));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (_captured.isEmpty && _textController.text.isEmpty) {
      _showMessage("Please provide either a photo or text.");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      List<String> urls = [];

      for (int i = 0; i < _captured.length; i++) {
        final url = await _upload(_captured[i], i);
        if (url != null) urls.add(url);
      }

      final payload = {
        "phq_responses": _phqAnswers,
        "text": _textController.text.trim(),
        "images": urls,
      };

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (res.statusCode != 200) {
        _showMessage("API error: ${res.statusCode}");
        return;
      }

      final data = jsonDecode(res.body);

      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("responses")
            .add({
          "timestamp": FieldValue.serverTimestamp(),
          "api_result": data,
          "images": urls,
          "phq_responses": _phqAnswers,
          "text": _textController.text.trim(),
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            apiResponse: data,
            phqAnswers: _phqAnswers,
            inputText: _textController.text,
            imageUrls: urls,
          ),
        ),
      );
    } catch (e) {
      _showMessage("Submission failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.indigo,
            title: const Text("Multimodal Assessment"),
          ),
          bottomNavigationBar: const BottomNavbar(currentIndex: 1),
          body: !_cameraReady
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // -------- CAMERA WITH STATUS --------
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CameraPreview(_controller!),
                    ),

                    // FACE STATUS
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          faceStatus,
                          style: TextStyle(
                            color: faceStatusColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // -------- CAPTURE BUTTON --------
              Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: _loading ? null : _captureAndDetect,
                  child: Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigo,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(.4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 32),
                  ),
                ),
              ),

              // -------- THUMBNAILS --------
              if (_captured.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _captured.length,
                    itemBuilder: (_, i) {
                      final f = _captured[i];
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(f.path),
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: GestureDetector(
                              onTap: () => setState(
                                      () => _captured.removeAt(i)),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 15),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),

              const Divider(),

              // -------- FORM AREA --------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("🧠 PHQ-10",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      ...List.generate(10, (i) {
                        final qNum = i + 1;
                        return Card(
                          elevation: 1,
                          child: ExpansionTile(
                            title: Text(_questions[i]),
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: List.generate(4, (score) {
                                  return Row(
                                    children: [
                                      Radio(
                                        value: score,
                                        groupValue:
                                        _phqAnswers["q$qNum"],
                                        onChanged: (v) => setState(() {
                                          _phqAnswers["q$qNum"] =
                                          v as int;
                                        }),
                                      ),
                                      Text("$score"),
                                    ],
                                  );
                                }),
                              )
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 12),
                      const Text("💬 Text Input",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _textController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Describe your feelings...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.analytics),
                          label: const Text("Analyze"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // -------- LOADING OVERLAY --------
        if (_loading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          )
      ],
    );
  }
}

const List<String> _questions = [
  "Little interest or pleasure in doing things",
  "Feeling down, depressed, or hopeless",
  "Trouble falling or staying asleep, or sleeping too much",
  "Feeling tired or having little energy",
  "Poor appetite or overeating",
  "Feeling bad about yourself or that you’re a failure",
  "Trouble concentrating",
  "Moving or speaking slowly / restlessness",
  "Thoughts of self-harm",
  "How difficult have these problems made life for you?",
];

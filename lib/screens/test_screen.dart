// Updated test_screen.dart - Upload images to Cloudinary and send URLs

import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/bottom_navbar.dart';
import 'result_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
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

  final Map<String, int> _phqAnswers = {for (int i = 1; i <= 10; i++) "q$i": 0};

  bool _loading = false;

  final String apiUrl = "https://akash297-tepi.hf.space/predict";

  // Cloudinary Configuration
  // IMPORTANT: Replace these with your actual Cloudinary credentials
  final String cloudinaryCloudName = "dqqrwpirf"; // e.g., "dxxxxxx"
  final String cloudinaryUploadPreset = "phq_image"; // Create an unsigned preset in Cloudinary settings

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      final front = _cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);

      _controller = CameraController(
        front,
        ResolutionPreset.medium,
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
        _showMessage("Only one face allowed.");
        await File(file.path).delete();
      } else {
        faceStatus = "Perfect!";
        faceStatusColor = Colors.green;
        setState(() => _captured.insert(0, file));
      }
    } catch (e) {
      _showMessage("Capture failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  // Upload image to Cloudinary and return URL
  Future<String?> _uploadToCloudinary(XFile file, int index) async {
    try {
      final imageFile = File(file.path);

      if (!imageFile.existsSync()) {
        print("❌ Upload failed: File does not exist at ${file.path}");
        return null;
      }

      final url = Uri.parse(
          "https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload"
      );

      final request = http.MultipartRequest('POST', url);

      // Add upload preset (unsigned upload)
      request.fields['upload_preset'] = cloudinaryUploadPreset;

      // Optional: Add folder organization
      request.fields['folder'] = 'patient_images';

      // Optional: Add timestamp to filename
      request.fields['public_id'] = 'image_${DateTime.now().millisecondsSinceEpoch}_$index';

      // Attach the image file
      request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path)
      );

      print("📤 Uploading image ${index + 1} to Cloudinary...");

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData);
        final imageUrl = jsonResponse['secure_url'] as String;
        print("✅ Image ${index + 1} uploaded: $imageUrl");
        return imageUrl;
      } else {
        print("❌ Cloudinary upload failed with status: ${response.statusCode}");
        print("Response: $responseData");
        return null;
      }
    } catch (e) {
      print("❌ Error uploading to Cloudinary: $e");
      return null;
    }
  }

  Future<void> _submit() async {
    if (_captured.isEmpty && _textController.text.trim().isEmpty) {
      _showMessage("Provide at least a valid face photo or text.");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Upload images to Cloudinary and collect URLs
      List<String> imageUrls = [];
      print("===== UPLOADING IMAGES TO CLOUDINARY =====");

      for (int i = 0; i < _captured.length; i++) {
        final url = await _uploadToCloudinary(_captured[i], i);
        if (url != null) {
          imageUrls.add(url);
        } else {
          print("⚠️ Failed to upload image ${i + 1}");
        }
      }

      if (_captured.isNotEmpty && imageUrls.isEmpty) {
        _showMessage("Failed to upload images. Please check your internet connection.");
        setState(() => _loading = false);
        return;
      }

      print("===== TOTAL URLs COLLECTED: ${imageUrls.length} =====");

      // Build payload with image URLs
      final payload = {
        "phq_responses": _phqAnswers,
        "text": _textController.text.trim(),
        "images": imageUrls, // ✅ Sending Cloudinary URLs
      };

      print("===== SENDING PAYLOAD TO BACKEND =====");
      print(jsonEncode(payload));

      final uri = Uri.parse(apiUrl);

      final res = await http
          .post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 60));

      print("===== API RESPONSE =====");
      print("STATUS CODE: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.statusCode != 200) {
        _showMessage("API error: ${res.statusCode}");
        return;
      }

      final data = jsonDecode(res.body);

      // Save to Firestore
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("assessments")
            .add({
          "timestamp": FieldValue.serverTimestamp(),
          "api_result": data,
          "images": imageUrls,
          "phq_responses": _phqAnswers,
          "text": _textController.text.trim(),
        });
      }

      // Navigate to results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            apiResponse: data,
            phqAnswers: _phqAnswers,
            inputText: _textController.text.trim(),
            imageUrls: imageUrls,
          ),
        ),
      );
    } catch (e) {
      print("===== SUBMISSION ERROR =====");
      print(e);
      _showMessage("Submission failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMessage(String msg) {
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
  void dispose() {
    _pulseController.dispose();
    _controller?.dispose();
    _faceDetector.close();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
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
            title: const Text(
              "Multimodal Assessment",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          bottomNavigationBar: const BottomNavbar(currentIndex: 1),
          body: !_cameraReady
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.indigo),
                const SizedBox(height: 16),
                Text(
                  "Initializing camera...",
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            child: Column(
              children: [
                // CAMERA SECTION
                Container(
                  margin: EdgeInsets.all(isDesktop ? 20 : 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: Stack(
                        children: [
                          CameraPreview(_controller!),

                          // Face status indicator
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: faceStatusColor.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: faceStatusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    faceStatus,
                                    style: TextStyle(
                                      color: faceStatusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isDesktop ? 16 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // CAPTURE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: GestureDetector(
                      onTap: _loading ? null : _captureAndDetect,
                      child: Container(
                        height: isDesktop ? 80 : 70,
                        width: isDesktop ? 80 : 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade400,
                              Colors.indigo.shade700,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: isDesktop ? 36 : 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // THUMBNAILS
                if (_captured.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 20 : 16,
                      vertical: 8,
                    ),
                    height: isDesktop ? 130 : 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _captured.length,
                      itemBuilder: (_, i) {
                        final f = _captured[i];
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(f.path),
                                  width: isDesktop ? 130 : 110,
                                  height: isDesktop ? 130 : 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _captured.removeAt(i));
                                  File(f.path).delete();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                // FORM AREA
                _buildForm(isDesktop, isTablet),
              ],
            ),
          ),
        ),

        // LOADING OVERLAY
        if (_loading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Processing your assessment...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildForm(bool isDesktop, bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
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
          // PHQ-10 Section Header
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
                  Icons.psychology_outlined,
                  color: Colors.white,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "PHQ-10 Questionnaire",
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Rate how often you've experienced these feelings (0-3)",
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),

          // PHQ Questions
          ...List.generate(10, (i) {
            final qNum = i + 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 16,
                  vertical: 8,
                ),
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "$qNum",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _questions[i],
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 20 : 16,
                      vertical: 12,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(4, (score) {
                        final isSelected = _phqAnswers["q$qNum"] == score;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _phqAnswers["q$qNum"] = score;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 24 : 20,
                              vertical: isDesktop ? 14 : 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                colors: [
                                  Colors.indigo.shade400,
                                  Colors.indigo.shade600,
                                ],
                              )
                                  : null,
                              color: isSelected ? null : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.indigo.shade400
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _scoreLabels[score],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: isDesktop ? 15 : 13,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // Text Input Section
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
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Text Input",
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Share your thoughts and feelings (optional)",
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _textController,
            maxLines: 5,
            style: TextStyle(fontSize: isDesktop ? 16 : 14),
            decoration: InputDecoration(
              hintText: "Describe how you're feeling today...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
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
              contentPadding: EdgeInsets.all(isDesktop ? 20 : 16),
            ),
          ),

          const SizedBox(height: 32),

          // Submit Button
          Center(
            child: Container(
              width: isDesktop ? 300 : double.infinity,
              height: isDesktop ? 56 : 52,
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.analytics, color: Colors.white),
                label: Text(
                  "Analyze Assessment",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 18 : 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> _questions = [
  "Little interest or pleasure in doing things",
  "Feeling down, depressed, or hopeless",
  "Trouble falling or staying asleep, or sleeping too much",
  "Feeling tired or having little energy",
  "Poor appetite or overeating",
  "Feeling bad about yourself or that you're a failure",
  "Trouble concentrating",
  "Moving or speaking slowly / restlessness",
  "Thoughts of self-harm",
  "How difficult have these problems made life for you?",
];

const List<String> _scoreLabels = [
  "Not at all",
  "Several days",
  "More than half",
  "Nearly every day",
];
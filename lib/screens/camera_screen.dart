import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/predict_service.dart';
import 'prediction_result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;

  bool _isCameraReady = false;
  bool _isTakingPicture = false;

  FlashMode _flashMode = FlashMode.off;
  List<CameraDescription> cameras = [];
  int cameraIndex = 0;

  double _currentZoom = 1.0;
  double _maxZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeEverything();
  }

  Future<void> _initializeEverything() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();

      cameraIndex = cameras.indexWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back);

      if (cameraIndex == -1) cameraIndex = 0;

      await _initializeCamera();
    } catch (e) {
      print("Camera init error: $e");
    }
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();

    _maxZoom = await _controller!.getMaxZoomLevel();

    if (!mounted) return;
    setState(() {
      _isCameraReady = true;
    });
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;

    cameraIndex = (cameraIndex + 1) % cameras.length;
    setState(() => _isCameraReady = false);

    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    if (_flashMode == FlashMode.off) {
      _flashMode = FlashMode.auto;
    } else if (_flashMode == FlashMode.auto) {
      _flashMode = FlashMode.always;
    } else {
      _flashMode = FlashMode.off;
    }

    await _controller!.setFlashMode(_flashMode);
    setState(() {});
  }

  Future<void> _takePhoto() async {
    if (!_controller!.value.isInitialized || _isTakingPicture) return;

    setState(() => _isTakingPicture = true);

    try {
      await _controller!.setFlashMode(_flashMode);

      final XFile file = await _controller!.takePicture();
      final imageFile = File(file.path);

      /// Loading overlay turned ON
      setState(() {});

      final result = await PredictService.predictFood(imageFile);

      if (!mounted) return;

      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PredictionResultScreen(
              label: result["label"],
              confidence: result["confidence"],
              calories: result["calories"],
              protein: result["protein_g"],
              fat: result["fat_g"],
              carbs: result["carbs_g"],
              image: imageFile,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prediction failed.")),
        );
      }
    } catch (e) {
      print("Take photo error: $e");
    }

    setState(() => _isTakingPicture = false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Icon _flashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return const Icon(Icons.flash_auto, color: Colors.white);
      case FlashMode.always:
        return const Icon(Icons.flash_on, color: Colors.white);
      default:
        return const Icon(Icons.flash_off, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: !_isCameraReady
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                /// CAMERA PREVIEW
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),

                /// BACK BUTTON
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                /// FLASH BUTTON
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: _flashIcon(),
                      onPressed: _toggleFlash,
                    ),
                  ),
                ),

                /// SWITCH CAMERA BUTTON
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 40),
                    child: IconButton(
                      icon: const Icon(Icons.cameraswitch,
                          color: Colors.white, size: 36),
                      onPressed: _switchCamera,
                    ),
                  ),
                ),

                /// ZOOM SLIDER
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 40),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: _currentZoom,
                        min: 1.0,
                        max: _maxZoom,
                        inactiveColor: Colors.white24,
                        activeColor: Colors.greenAccent,
                        onChanged: (v) async {
                          setState(() => _currentZoom = v);
                          await _controller?.setZoomLevel(v);
                        },
                      ),
                    ),
                  ),
                ),

                /// CAPTURE BUTTON
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: GestureDetector(
                      onTap: _takePhoto,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _isTakingPicture ? 70 : 80,
                        height: _isTakingPicture ? 70 : 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _isTakingPicture ? Colors.grey : Colors.white,
                          border: Border.all(
                              color: Colors.white, width: 4),
                        ),
                      ),
                    ),
                  ),
                ),

                /// LOADING OVERLAY WHEN PREDICTING
                if (_isTakingPicture)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

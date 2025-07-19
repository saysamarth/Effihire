import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'anti_spoofing_service.dart';

// Service class to handle photo capture operations
class PhotoCaptureService {
  bool _isInitialized = false;
  List<CameraDescription>? _availableCameras;

  /// Initialize the photo capture service
  Future<void> initializeService() async {
    if (_isInitialized) return;

    try {
      _availableCameras = await availableCameras();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize photo capture service: $e');
    }
  }

  /// Check if front camera is available
  bool get hasFrontCamera {
    if (!_isInitialized || _availableCameras == null) return false;

    return _availableCameras!.any(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
  }

  /// Capture selfie (front camera only)
  Future<File?> captureSelfie({
    required BuildContext context,
    bool showPreview = true,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'PhotoCaptureService not initialized. Call initializeService() first.',
      );
    }

    try {
      final result = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoCaptureScreen(showPreview: showPreview),
        ),
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to capture photo: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
    _availableCameras = null;
  }
}

// Selfie-only PhotoCaptureScreen
class PhotoCaptureScreen extends StatefulWidget {
  final bool showPreview;

  const PhotoCaptureScreen({super.key, this.showPreview = true});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isCapturing = false;
  String? _errorMessage;

  // Anti-spoofing state variables
  final AntiSpoofingService _antiSpoofingService = AntiSpoofingService();
  bool _isProcessingFrame = false;
  String _statusMessage = 'Position your face within the oval guide';
  bool _isCaptureEnabled = false;
  StatusType _statusType = StatusType.initial;

  // Timer to control the rate of frame processing
  Timer? _frameProcessingTimer;
  CameraImage? _latestImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllerFuture = _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _frameProcessingTimer?.cancel();
    if (_controller?.value.isInitialized == true &&
        _controller!.value.isStreamingImages) {
      _controller!.stopImageStream();
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _frameProcessingTimer?.cancel();
      if (cameraController.value.isStreamingImages) {
        cameraController.stopImageStream();
      }
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    _frameProcessingTimer?.cancel();

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => throw Exception('Front camera not found'),
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Changed to medium resolution
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _controller!.initialize();

      if (!mounted) {
        return;
      }

      _controller!.startImageStream((image) => _latestImage = image);

      _frameProcessingTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) {
          if (_isProcessingFrame || _latestImage == null || _isCaptureEnabled)
            return;
          _processFrame();
        },
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _processFrame() async {
    _isProcessingFrame = true;
    final result = await _antiSpoofingService.processImage(_latestImage!);

    if (mounted) {
      setState(() {
        _statusMessage = result.statusMessage;
        _statusType = result.statusType;
        _isCaptureEnabled = result.isCaptureEnabled;
      });

      if (_isCaptureEnabled) {
        _frameProcessingTimer?.cancel();
        if (_controller!.value.isStreamingImages) {
          _controller!.stopImageStream();
        }
      }
    }

    _isProcessingFrame = false;
  }

  Future<void> _capturePhoto() async {
    if (_controller?.value.isInitialized != true ||
        _isCapturing ||
        !_isCaptureEnabled)
      return;

    try {
      setState(() {
        _isCapturing = true;
      });

      _frameProcessingTimer?.cancel();
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      final XFile image = await _controller!.takePicture();

      if (widget.showPreview) {
        setState(() {
          _capturedImage = image;
          _isCapturing = false;
        });
      } else {
        if (mounted) {
          Navigator.pop(context, image);
        }
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to capture photo: ${e.toString()}';
      });
    }
  }

  void _retakePhoto() {
    _antiSpoofingService.reset();
    setState(() {
      _capturedImage = null;
      _isCaptureEnabled = false;
      _statusMessage = 'Position your face within the oval guide';
      _statusType = StatusType.initial;
      // FIX: Set controller to null before re-initializing to avoid disposed error
      _controller = null;
    });
    _initializeControllerFuture = _initializeCamera();
  }

  void _confirmPhoto() {
    Navigator.pop(context, _capturedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _capturedImage != null ? 'Photo Preview' : 'Take Selfie',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    if (_capturedImage != null && widget.showPreview) {
      return _buildPhotoPreview();
    }
    return _buildCameraView();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
              _initializeControllerFuture = _initializeCamera();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        // Use a local variable to avoid race conditions with the controller
        final controller = _controller;
        if (snapshot.connectionState == ConnectionState.done &&
            controller != null &&
            controller.value.isInitialized) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14159),
                          child: CameraPreview(controller),
                        ),
                      ),
                    ),
                    _buildGreyOverlay(),
                    _buildInstructions(),
                  ],
                ),
              ),
              _buildCameraControls(),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 3,
            ),
          );
        }
      },
    );
  }

  Widget _buildGreyOverlay() {
    return CustomPaint(
      painter: OvalCutoutPainter(statusType: _statusType),
      size: Size.infinite,
    );
  }

  Widget _buildInstructions() {
    Color statusColor;
    switch (_statusType) {
      case StatusType.inProgress:
        statusColor = Colors.orange.withAlpha(200);
        break;
      case StatusType.success:
        statusColor = Colors.green.withAlpha(200);
        break;
      case StatusType.error:
        statusColor = Colors.red.withAlpha(200);
        break;
      case StatusType.initial:
      default:
        statusColor = Colors.black.withAlpha(175);
    }

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _statusMessage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 64),
          GestureDetector(
            onTap: _isCapturing || !_isCaptureEnabled ? null : _capturePhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isCaptureEnabled ? Colors.white : Colors.grey[700],
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isCaptureEnabled ? Colors.green : Colors.blue,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(75),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isCapturing
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isCaptureEnabled ? Colors.green : Colors.blue,
                        ),
                        strokeWidth: 3,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      color: _isCaptureEnabled ? Colors.green : Colors.blue,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: 64),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(75),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
            ),
          ),
        ),
        _buildPreviewControls(),
      ],
    );
  }

  Widget _buildPreviewControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _retakePhoto,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Retake',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _confirmPhoto,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to create grey overlay with oval cutout
class OvalCutoutPainter extends CustomPainter {
  final StatusType statusType;

  OvalCutoutPainter({this.statusType = StatusType.initial});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha(150)
      ..style = PaintingStyle.fill;

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    // Adjusted oval size
    final ovalRect = Rect.fromCenter(center: center, width: 200, height: 280);
    final ovalPath = Path()..addOval(ovalRect);

    final finalPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(fullRect),
      ovalPath,
    );

    canvas.drawPath(finalPath, paint);

    Color borderColor;
    switch (statusType) {
      case StatusType.inProgress:
        borderColor = Colors.orange;
        break;
      case StatusType.success:
        borderColor = Colors.green;
        break;
      case StatusType.error:
        borderColor = Colors.red;
        break;
      case StatusType.initial:
      default:
        borderColor = Colors.white.withAlpha(200);
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(ovalRect, borderPaint);

    final innerBorderPaint = Paint()
      ..color = borderColor.withAlpha(75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Adjusted inner oval size to match
    final innerOvalRect = Rect.fromCenter(
      center: center,
      width: 196,
      height: 276,
    );

    canvas.drawOval(innerOvalRect, innerBorderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      oldDelegate is! OvalCutoutPainter || statusType != oldDelegate.statusType;
}

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

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
      throw Exception('PhotoCaptureService not initialized. Call initializeService() first.');
    }

    try {
      final result = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoCaptureScreen(
            showPreview: showPreview,
          ),
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

  const PhotoCaptureScreen({
    super.key,
    this.showPreview = true,
  });

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      
      // Find front camera only
      CameraDescription? frontCamera;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (frontCamera == null) {
        setState(() {
          _errorMessage = 'Front camera not available';
        });
        return;
      }

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller?.value.isInitialized != true || _isCapturing) return;

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile image = await _controller!.takePicture();
      
      if (widget.showPreview) {
        setState(() {
          _capturedImage = image;
          _isCapturing = false;
        });
      } else {
        // Return immediately without preview
        if(mounted){
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
    setState(() {
      _capturedImage = null;
    });
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
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeCamera,
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
        if (snapshot.connectionState == ConnectionState.done &&
            _controller?.value.isInitialized == true) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Camera preview
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14159), // Mirror for front camera
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                    // Grey overlay with oval cutout
                    _buildGreyOverlay(),
                    // Instructions
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
      painter: OvalCutoutPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(175),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Position your face within the oval guide',
          style: TextStyle(
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
            onTap: _isCapturing ? null : _capturePhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isCapturing ? Colors.grey : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue,
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.blue,
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
              child: Image.file(
                File(_capturedImage!.path),
                fit: BoxFit.cover,
              ),
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
          // Retake button
          ElevatedButton(
            onPressed: _retakePhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Retake',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Confirm button
          ElevatedButton(
            onPressed: _confirmPhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to create grey overlay with oval cutout
class OvalCutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha(150)
      ..style = PaintingStyle.fill;

    // Create the full rectangle
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Create the oval cutout path
    final ovalPath = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: 190,
      height: 260,
    );
    
    ovalPath.addOval(ovalRect);
    
    // Create the final path by subtracting the oval from the full rectangle
    final finalPath = Path()
      ..addRect(fullRect)
      ..addPath(ovalPath, Offset.zero);
    
    // Use the even-odd fill rule to create the cutout effect
    finalPath.fillType = PathFillType.evenOdd;
    
    canvas.drawPath(finalPath, paint);
    
    // Draw the oval border
    final borderPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawOval(ovalRect, borderPaint);
    
    // Draw inner border
    final innerBorderPaint = Paint()
      ..color = Colors.blue.withAlpha(75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final innerOvalRect = Rect.fromCenter(
      center: center,
      width: 186,
      height: 256,
    );
    
    canvas.drawOval(innerOvalRect, innerBorderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
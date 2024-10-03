import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './video_preview_screen.dart';

class VideoRecordingScreen extends StatefulWidget {
  static const String routeName = "postVideo";
  static const String routeURL = "/upload";
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isSelfieMode = false;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera(CameraLensDirection.back);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(CameraLensDirection.back);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _cameraController.buildPreview(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isRecording
                    ? IconButton(
                        icon: Icon(
                          _isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                        ),
                        onPressed: () => _pauseResumeRecording())
                    : const SizedBox(),
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.circle,
                    color: Colors.white,
                  ),
                  onPressed: () => _recordVideo(),
                ),
                !_isRecording
                    ? IconButton(
                        color: Colors.white,
                        onPressed: () => _toggleSelfieMode(),
                        icon: const Icon(
                          Icons.cameraswitch,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initCamera(CameraLensDirection direction) async {
    try {
      final cameras = await availableCameras();
      final availableCamera =
          cameras.firstWhere((camera) => camera.lensDirection == direction);
      _cameraController =
          CameraController(availableCamera, ResolutionPreset.high);

      await _cameraController.initialize();
      await _cameraController
          .lockCaptureOrientation(DeviceOrientation.portraitUp);

      setState(() => _isLoading = false);
    } on CameraException catch (e) {
      log('${e.code}: ${e.description}');
    }
  }

  Future<void> _recordVideo() async {
    if (_isRecording) {
      try {
        final file = await _cameraController.stopVideoRecording();
        setState(() => _isRecording = false);

        final route = MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => VideoPreviewScreen(videoPreview: File(file.path)),
        );

        if (!mounted) return;

        Navigator.push(context, route);
      } on CameraException catch (e) {
        log('${e.code}: ${e.description}');
      }
    } else {
      try {
        await _cameraController.prepareForVideoRecording();
        await _cameraController.startVideoRecording();

        setState(() => _isRecording = true);
      } on CameraException catch (e) {
        log('${e.code}: ${e.description}');
      }
    }
  }

  Future<void> _toggleSelfieMode() async {
    await _cameraController.dispose();
    await _initCamera(
        _isSelfieMode ? CameraLensDirection.back : CameraLensDirection.front);

    setState(() {
      _isSelfieMode = !_isSelfieMode;
    });
  }

  Future<void> _pauseResumeRecording() async {
    if (_isPaused) {
      await _cameraController.resumeVideoRecording();
    } else {
      await _cameraController.pauseVideoRecording();
    }

    setState(() {
      _isPaused = !_isPaused;
    });
  }
}

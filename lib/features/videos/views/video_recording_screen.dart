import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/sizes.dart';
import './video_preview_screen.dart';

class VideoRecordingScreen extends StatefulWidget {
  static const String routeName = "postVideo";
  static const String routeURL = "/upload";
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isSelfieMode = false;
  double _maximumZoomLevel = 0.0;
  double _minimumZoomLevel = 0.0;
  double _currentZoomLevel = 0.0;
  final double _zoomLevelStep = 0.05;
  late CameraController _cameraController;

  late final AnimationController _buttonAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  late final Animation<double> _buttonAnimation =
      Tween(begin: 1.0, end: 1.3).animate(_buttonAnimationController);

  late final AnimationController _progressAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  @override
  void initState() {
    super.initState();
    _initCamera(CameraLensDirection.back);

    WidgetsBinding.instance.addObserver(this);
    _progressAnimationController.addListener(() {
      setState(() {});
    });
    _progressAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //_stopRecording();
      }
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _progressAnimationController.dispose();
    _buttonAnimationController.dispose();
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
            Positioned(
              top: Sizes.size20,
              right: Sizes.size20,
              child: Column(
                children: [
                  IconButton(
                    color: Colors.white,
                    onPressed: _toggleSelfieMode,
                    icon: const Icon(
                      Icons.cameraswitch,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: Sizes.size40,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onVerticalDragUpdate: (details) =>
                        _onVerticalDragUpdate(details, context),
                    onTapDown: (details) => _recordVideo(),
                    onTapUp: (details) => _pauseRecording(),
                    child: ScaleTransition(
                      scale: _buttonAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: Sizes.size80 + Sizes.size14,
                            height: Sizes.size80 + Sizes.size14,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: Sizes.size4,
                              value: _progressAnimationController.value,
                            ),
                          ),
                          Container(
                            width: Sizes.size80,
                            height: Sizes.size80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     child: IconButton(
                  //       onPressed: _onPickVideoPressed,
                  //       icon: const FaIcon(
                  //         FontAwesomeIcons.image,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            )
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
      _maximumZoomLevel = await _cameraController.getMaxZoomLevel();
      _minimumZoomLevel = await _cameraController.getMinZoomLevel();

      setState(() {
        _isLoading = false;
      });
    } on CameraException catch (e) {
      log('${e.code}: ${e.description}');
    }
  }

  Future<void> _recordVideo() async {
    if (_isRecording && _isPaused) {
      try {
        await _cameraController.resumeVideoRecording();

        _buttonAnimationController.forward();
        _progressAnimationController.forward();
      } on CameraException catch (e) {
        log('${e.code}: ${e.description}');
      }
    } else {
      try {
        await _cameraController.prepareForVideoRecording();
        await _cameraController.startVideoRecording();

        _buttonAnimationController.forward();
        _progressAnimationController.forward();

        setState(() => _isRecording = true);
      } on CameraException catch (e) {
        log('${e.code}: ${e.description}');
      }
    }
  }

  Future<void> _stopRecording() async {
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
  }

  Future<void> _toggleSelfieMode() async {
    await _cameraController.dispose();
    await _initCamera(
        _isSelfieMode ? CameraLensDirection.back : CameraLensDirection.front);

    setState(() {
      _isSelfieMode = !_isSelfieMode;
    });
  }

  Future<void> _pauseRecording() async {
    if (_isRecording && !_isPaused) {
      await _cameraController.pauseVideoRecording();

      _buttonAnimationController.stop();
      _progressAnimationController.stop();
    }

    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _onVerticalDragUpdate(
      DragUpdateDetails details, BuildContext context) async {
    if (details.delta.dy < 0 && _currentZoomLevel < _maximumZoomLevel) {
      _currentZoomLevel += _zoomLevelStep;
    } else if (details.delta.dy > 0 && _currentZoomLevel > _minimumZoomLevel) {
      _currentZoomLevel -= _zoomLevelStep;
    }
    _currentZoomLevel =
        _currentZoomLevel.clamp(_minimumZoomLevel, _maximumZoomLevel);
    _cameraController.setZoomLevel(_currentZoomLevel);

    setState(() {});
  }
}

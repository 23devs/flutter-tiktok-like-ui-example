// ignore_for_file: avoid_print

// import 'dart:io';

// import 'package:path/path.dart' as path;
import 'dart:io';

import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impetus_test/features/videos/views/video_preview_screen.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:impetus_test/constants/gaps.dart';
// import 'package:impetus_test/constants/sizes.dart';
// import 'package:impetus_test/features/videos/views/video_preview_screen.dart';
// import 'package:impetus_test/features/videos/views/widgets/video_flash_button.dart';

class VideoRecordingScreen extends StatefulWidget {
  static const String routeName = "postVideo";
  static const String routeURL = "/upload";
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
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
            Padding(
              padding: const EdgeInsets.all(25),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(_isRecording ? Icons.stop : Icons.circle),
                onPressed: () => _recordVideo(),
              ),
            ),
          ],
        ),
      );
    }
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(backCamera, ResolutionPreset.high);
    await _cameraController.initialize();
    await _cameraController
        .lockCaptureOrientation(DeviceOrientation.portraitUp);

    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPreviewScreen(videoPreview: File(file.path)),
      );

      if (!mounted) return;

      Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  // bool _hasPermission = false;
  // List<String> _deniedPermissions = [];
  // bool _isSelfieMode = false;
  // bool _isRecording = false;
  // bool _isLoading = false;
  // double _maximumZoomLevel = 0.0;
  // double _minimumZoomLevel = 0.0;
  // double _currentZoomLevel = 0.0;
  // final double _zoomLevelStep = 0.05;

  // late final bool _noCamera = kDebugMode && Platform.isIOS;

  // // late final AnimationController _buttonAnimationController =
  // //     AnimationController(
  // //   vsync: this,
  // //   duration: const Duration(milliseconds: 200),
  // // );

  // // late final Animation<double> _buttonAnimation =
  // //     Tween(begin: 1.0, end: 1.3).animate(_buttonAnimationController);

  // // late final AnimationController _progressAnimationController =
  // //     AnimationController(
  // //   vsync: this,
  // //   duration: const Duration(seconds: 10),
  // //   lowerBound: 0.0,
  // //   upperBound: 1.0,
  // // );

  // late FlashMode _flashMode;
  // late CameraController _cameraController;

  // @override
  // void initState() {
  //   super.initState();
  //   if (!_noCamera) {
  //     initPermissions();
  //   } else {
  //     setState(() {
  //       _hasPermission = true;
  //     });
  //     initCamera();
  //   }
  //   WidgetsBinding.instance.addObserver(this);
  //   // _progressAnimationController.addListener(() {
  //   //   setState(() {});
  //   // });
  //   // _progressAnimationController.addStatusListener((status) {
  //   //   if (status == AnimationStatus.completed) {
  //   //     _stopRecording();
  //   //   }
  //   // });
  // }

  // @override
  // void dispose() {
  //   // _progressAnimationController.dispose();
  //   // _buttonAnimationController.dispose();

  //   if (!_noCamera) {
  //     _cameraController.dispose();
  //   }
  //   super.dispose();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (_noCamera) return;
  //   if (!_hasPermission) return;
  //   if (!_cameraController.value.isInitialized) return;
  //   if (state == AppLifecycleState.inactive) {
  //     _cameraController.dispose();
  //   } else if (state == AppLifecycleState.resumed) {
  //     initCamera();
  //   }
  // }

  // Future<void> initCamera() async {
  //   final cameras = await availableCameras();

  //   if (cameras.isEmpty) {
  //     return;
  //   }

  //   final back = cameras.firstWhere(
  //       (camera) => camera.lensDirection == CameraLensDirection.back);
  //   _cameraController =
  //       CameraController(back, ResolutionPreset.max, enableAudio: false);

  //   await _cameraController.initialize();

  //   setState(() => _isLoading = false);
  // }

  // Future<void> initPermissions() async {
  //   final cameraPermission = await Permission.camera.request();
  //   final micPermission = await Permission.microphone.request();

  //   final cameraDenied =
  //       cameraPermission.isDenied || cameraPermission.isPermanentlyDenied;

  //   final micDenied =
  //       micPermission.isDenied || micPermission.isPermanentlyDenied;

  //   if (!cameraDenied && !micDenied) {
  //     _hasPermission = true;
  //     await initCamera();
  //   } else {
  //     _deniedPermissions = [
  //       if (cameraDenied) "Camera",
  //       if (micDenied) "Microphone",
  //     ];
  //   }
  // }

  // Future<void> _toggleSelfieMode() async {
  //   await initCamera();
  //   setState(() {
  //     _isSelfieMode = !_isSelfieMode;
  //   });
  // }

  // Future<void> _setFlashMode(FlashMode newFlashMode) async {
  //   await _cameraController.setFlashMode(newFlashMode);

  //   setState(() {
  //     _flashMode = newFlashMode;
  //   });
  // }

  // // Future<void> _startRecording() async {
  // //   if (_cameraController.value.isRecordingVideo) return;

  // //   await _cameraController.startVideoRecording();

  // //   _buttonAnimationController.forward();
  // //   _progressAnimationController.forward();
  // // }

  // Future<void> _stopRecording() async {
  //   if (!_cameraController.value.isRecordingVideo) return;

  //   //_buttonAnimationController.reverse();
  //   //_progressAnimationController.reset();

  //   final video = await _cameraController.stopVideoRecording();

  //   print('on stop recording');
  //   print(video.name);
  //   print(video.path);

  //   final videoPreview = await saveVideo(video);

  //   if (!mounted) return;

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => VideoPreviewScreen(
  //         videoPreview: videoPreview,
  //         isPicked: false,
  //       ),
  //     ),
  //   );
  // }

  // // Future<void> _onPickVideoPressed() async {
  // //   final video = await ImagePicker().pickVideo(
  // //     source: ImageSource.gallery,
  // //   );
  // //   if (video == null) return;

  // //   final File videoPreview = await saveVideo(video);

  // //   if (!mounted) return;

  // //   print('on pick video pressed');
  // //   print(videoPreview.path);

  // //   Navigator.push(
  // //     context,
  // //     MaterialPageRoute(
  // //       builder: (context) => VideoPreviewScreen(
  // //         videoPreview: videoPreview,
  // //         isPicked: true,
  // //       ),
  // //     ),
  // //   );
  // // }

  // onVerticalDragUpdate(DragUpdateDetails details, BuildContext context) async {
  //   if (details.delta.dy < 0 && _currentZoomLevel < _maximumZoomLevel) {
  //     _currentZoomLevel += _zoomLevelStep;
  //   } else if (details.delta.dy > 0 && _currentZoomLevel > _minimumZoomLevel) {
  //     _currentZoomLevel -= _zoomLevelStep;
  //   }
  //   _currentZoomLevel =
  //       _currentZoomLevel.clamp(_minimumZoomLevel, _maximumZoomLevel);
  //   _cameraController.setZoomLevel(_currentZoomLevel);
  // }

  // Future<File> saveVideo(XFile video) async {
  //   final Directory tempDir = await getTemporaryDirectory();
  //   final String tempPath = video.path;
  //   if (video.path.endsWith('.temp')) {
  //     final String newFileName = path.join(
  //         tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.mp4');
  //     final File tempFile = File(tempPath);
  //     final File newFile = tempFile.renameSync(newFileName);
  //     return newFile;
  //   }
  //   return File(video.path);
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.black,
  //     body: SizedBox(
  //       width: MediaQuery.of(context).size.width,
  //       child: _isLoading
  //           ? Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const Text(
  //                   "Initializing...",
  //                   style:
  //                       TextStyle(color: Colors.white, fontSize: Sizes.size20),
  //                 ),
  //                 Gaps.v20,
  //                 const CircularProgressIndicator.adaptive(),
  //                 Gaps.v20,
  //                 !_hasPermission
  //                     ? Column(
  //                         children: [
  //                           const Text(
  //                             "Please grant the following permissions:",
  //                             style: TextStyle(
  //                                 color: Colors.white, fontSize: Sizes.size20),
  //                           ),
  //                           Gaps.v20,
  //                           _deniedPermissions.isEmpty
  //                               ? const SizedBox()
  //                               : Text(
  //                                   "• ${_deniedPermissions.join(", ")}",
  //                                   style: const TextStyle(
  //                                       color: Colors.white,
  //                                       fontSize: Sizes.size20),
  //                                 ),
  //                         ],
  //                       )
  //                     : Container()
  //               ],
  //             )
  //           : Stack(
  //               alignment: Alignment.center,
  //               children: [
  //                 if (!_noCamera && _cameraController.value.isInitialized)
  //                   CameraPreview(_cameraController),
  //                 const Positioned(
  //                   top: Sizes.size40,
  //                   left: Sizes.size20,
  //                   child: CloseButton(
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 if (!_noCamera)
  //                   Positioned(
  //                     top: Sizes.size20,
  //                     right: Sizes.size20,
  //                     child: Column(
  //                       children: [
  //                         IconButton(
  //                           color: Colors.white,
  //                           onPressed: _toggleSelfieMode,
  //                           icon: const Icon(
  //                             Icons.cameraswitch,
  //                           ),
  //                         ),
  //                         Gaps.v10,
  //                         VideoFlashButton(
  //                           flashMode: _flashMode,
  //                           targetMode: FlashMode.off,
  //                           setFlashMode: _setFlashMode,
  //                           icon: Icons.flash_off_rounded,
  //                         ),
  //                         Gaps.v10,
  //                         VideoFlashButton(
  //                           flashMode: _flashMode,
  //                           targetMode: FlashMode.always,
  //                           setFlashMode: _setFlashMode,
  //                           icon: Icons.flash_on_rounded,
  //                         ),
  //                         Gaps.v10,
  //                         VideoFlashButton(
  //                           flashMode: _flashMode,
  //                           targetMode: FlashMode.auto,
  //                           setFlashMode: _setFlashMode,
  //                           icon: Icons.flash_auto_rounded,
  //                         ),
  //                         Gaps.v10,
  //                         VideoFlashButton(
  //                           flashMode: _flashMode,
  //                           targetMode: FlashMode.torch,
  //                           setFlashMode: _setFlashMode,
  //                           icon: Icons.flashlight_on_rounded,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 Positioned(
  //                   bottom: Sizes.size40,
  //                   width: MediaQuery.of(context).size.width,
  //                   child: Row(
  //                     children: [
  //                       const Spacer(),
  //                       GestureDetector(
  //                         onVerticalDragUpdate: (details) =>
  //                             onVerticalDragUpdate(details, context),
  //                         onTap: () async {
  //                           try {
  //                             // await _cameraController.initialize();

  //                             await _cameraController
  //                                 .prepareForVideoRecording(); // for IOS

  //                             _flashMode = _cameraController.value.flashMode;
  //                             _maximumZoomLevel =
  //                                 await _cameraController.getMaxZoomLevel();
  //                             _minimumZoomLevel =
  //                                 await _cameraController.getMinZoomLevel();

  //                             if (!mounted) {
  //                               return;
  //                             }
  //                             if (_isRecording) {
  //                               await _stopRecording();
  //                             } else {
  //                               await _cameraController
  //                                   .prepareForVideoRecording();
  //                               print('on start recording');
  //                               await _cameraController.startVideoRecording();
  //                             }

  //                             setState(() {
  //                               _isRecording = !_isRecording;
  //                             });
  //                           } catch (e) {
  //                             print(e);
  //                           }
  //                         },
  //                         //onTapDown: _startRecording,
  //                         //onTapUp: (details) => _stopRecording(),
  //                         child: Container(
  //                           width: Sizes.size80,
  //                           height: Sizes.size80,
  //                           decoration: BoxDecoration(
  //                             shape: BoxShape.circle,
  //                             color: Colors.red.shade400,
  //                           ),
  //                           child: Center(
  //                             child: Icon(
  //                               _isRecording ? Icons.stop : Icons.circle,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                         ),
  //                         // ScaleTransition(
  //                         //   scale: _buttonAnimation,
  //                         //   child: Stack(
  //                         //     alignment: Alignment.center,
  //                         //     children: [
  //                         //       SizedBox(
  //                         //         width: Sizes.size80 + Sizes.size14,
  //                         //         height: Sizes.size80 + Sizes.size14,
  //                         //         child: CircularProgressIndicator(
  //                         //           color: Colors.red.shade400,
  //                         //           strokeWidth: Sizes.size6,
  //                         //           value: _progressAnimationController.value,
  //                         //         ),
  //                         //       ),
  //                         //       Container(
  //                         //         width: Sizes.size80,
  //                         //         height: Sizes.size80,
  //                         //         decoration: BoxDecoration(
  //                         //           shape: BoxShape.circle,
  //                         //           color: Colors.red.shade400,
  //                         //         ),
  //                         //       ),
  //                         //     ],
  //                         //   ),
  //                         // ),
  //                       ),
  //                       // Expanded(
  //                       //   child: Container(
  //                       //     alignment: Alignment.center,
  //                       //     child: IconButton(
  //                       //       onPressed: _onPickVideoPressed,
  //                       //       icon: const FaIcon(
  //                       //         FontAwesomeIcons.image,
  //                       //         color: Colors.white,
  //                       //       ),
  //                       //     ),
  //                       //   ),
  //                       // )
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //     ),
  //   );
  // }
}

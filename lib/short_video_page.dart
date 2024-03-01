import 'dart:async';
import 'dart:io';
import 'package:camera_app/camera_page.dart';
import 'package:camera_app/scanner_page.dart';
import 'package:camera_app/video_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class ShortVideoPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const ShortVideoPage({required this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<ShortVideoPage> {
  late CameraController controller;
  double _baseScale = 1.0;

  int secCount = 0;
  int minCount = 0;
  late Timer timer;
  XFile? pictureFile;
  int description = 0;
  bool isPhotoMode = true;
  bool frontCamera = true;
  double _zoomValue = 1.0;
  bool? isFlashOn = false;
  bool flashClicked = false;
  bool isRecording = false;
  String _videoPath = '';
  FlashMode flashMode = FlashMode.auto;
  Offset? _focusPoint;
  Icon flashIcon = Icon(
    Icons.flash_auto,
    color: Colors.amber,
  );

  @override
  void initState() {
    super.initState();
    startCamera(description);
  }

  Future<void> captureImage() async {
    if (controller.value.isTakingPicture) return;
    try {
      pictureFile = await controller.takePicture();
      if (pictureFile == null) return;

      await GallerySaver.saveImage(pictureFile!.path);

      changeState();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> pickImage() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pictureFile = pickedFile;
      changeState();
    }
  }

  Future<void> pickVideo() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pictureFile = pickedFile;
      changeState();
    }
  }

  void startCamera(int description) {
    controller =
        CameraController(widget.cameras![description], ResolutionPreset.high);
    controller.initialize().then((_) async {
      await controller.setFlashMode(flashMode);
      if (!mounted) {
        return;
      }
      changeState();
    });
  }

  void zoomCamera(double zoom) {
    _zoomValue = zoom;
    controller.setZoomLevel(zoom);
    changeState();
  }

  Future<void> setCameraFocusPoint(Offset relativeTapPosition) async {
    print(
        relativeTapPosition.dx.toString() + relativeTapPosition.dy.toString());
    if (!controller.value.isInitialized && controller == null) return;
    try {
      final double dx = relativeTapPosition.dx.clamp(0.0, 0.1);
      final double dy = relativeTapPosition.dy.clamp(0.0, 0.1);
      _focusPoint = Offset(dx, dy);

      await controller.setFocusPoint(_focusPoint!);
      await controller.setFocusMode(FocusMode.auto);
      print(dx.toString() + "  " + dy.toString());
      changeState();
      await Future.delayed(Duration(seconds: 2));
      _focusPoint = null;
      changeState();
    } catch (e) {
      print(e.toString());
    }
  }

  void toggleCamera() {
    description = description == 0 ? 1 : 0;
    startCamera(description);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void changeState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleRecording() {
    if (controller.value.isRecordingVideo) {
      isRecording = false;
      _stopRecording();
    } else {
      isRecording = true;
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!controller.value.isRecordingVideo) {
      final Directory dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/video_${DateTime.now().microsecondsSinceEpoch}.mp4';
      try {
        await controller.initialize();
        await controller.startVideoRecording();
        startTimer();

        _videoPath = path;
        changeState();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _stopRecording() async {
    if (controller.value.isRecordingVideo) {
      try {
        final XFile videoFile = await controller.stopVideoRecording();
        isRecording = false;
        stopTimer();
        pictureFile = videoFile;
        if (_videoPath.isNotEmpty) {
          final File file = File(videoFile.path);
          await file.copy(_videoPath);
          await GallerySaver.saveVideo(_videoPath);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void startTimer() async {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      secCount++;
      if (secCount == 11) {
        isRecording = false;
        _stopRecording();
      }
      changeState();
    });
  }

  void stopTimer() {
    timer.cancel();
    minCount = 0;
    secCount = 0;
    changeState();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Video'),
        //   centerTitle: true,
        //   automaticallyImplyLeading: false,
        //   elevation: 20,
        // ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                    child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: GestureDetector(
                            onScaleStart: (details) {
                              _baseScale = _zoomValue;
                            },
                            onScaleUpdate: (details) {
                              final double newScale =
                                  _baseScale * details.scale;
                              if (newScale.clamp(1.0, 4.0) != newScale) return;
                              _zoomValue = newScale;
                              zoomCamera(_zoomValue);
                              changeState();
                            },
                            onTapDown: (details) {
                              final Offset tapPosition = details.localPosition;

                              final Offset relativeTapPosition = Offset(
                                  tapPosition.dx / constraints.maxWidth,
                                  tapPosition.dy / constraints.maxHeight);
                              setCameraFocusPoint(relativeTapPosition);
                            },
                            child: CameraPreview(controller)))),
                Positioned(
                    bottom: 200,
                    right: 100,
                    child: Slider(
                      activeColor: Colors.amber,
                      inactiveColor: Colors.white,
                      thumbColor: Colors.white,
                      value: _zoomValue,
                      min: 1.0,
                      max: 4.0,
                      onChanged: (value) {
                        zoomCamera(value);
                        // changeState();
                      },
                    )),
                if (_focusPoint != null)
                  Positioned.fill(
                    top: _focusPoint!.dy * constraints.maxHeight,
                    child: Align(
                      alignment: Alignment(
                          _focusPoint!.dx * 2 - 1, _focusPoint!.dy * 2 - 1),
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white)),
                      ),
                    ),
                  ),
                Positioned(
                  top: 30,
                  left: MediaQuery.of(context).size.width * 0.45,
                  child: Visibility(
                    visible: isRecording,
                    child: Text(
                      "${minCount.toString().padLeft(2, '0')}:${secCount.toString().padLeft(2, '0')}",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 20,
                  right: 20,
                  child: Visibility(
                    visible: !isRecording,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () async {
                              flashClicked = !flashClicked;
                              setState(() {});
                            },
                            child: flashClicked
                                ? flashRow(context)
                                : SizedBox(
                                    height: 50, width: 50, child: flashIcon)),
                        Visibility(
                          visible: flashClicked ? false : true,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MobileScannerPage(
                                      cameras: widget.cameras),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    left: 10,
                    right: 10,
                    bottom: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (controller.value.isInitialized &&
                                !controller.value.isRecordingVideo) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CameraPage(cameras: widget.cameras),
                                  )).then(
                                (value) {
                                  // Navigator.pop(context);
                                  Navigator.popUntil(context, (route) => false);
                                  controller.dispose();
                                },
                              );
                            }
                          },
                          child: Text(
                            'Photo',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (controller.value.isInitialized) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VideoPage(cameras: widget.cameras),
                                ),
                              ).then(
                                (value) {
                                  // Navigator.pop(context);
                                  Navigator.popUntil(context, (route) => false);
                                  controller.dispose();
                                },
                              );
                            }
                          },
                          child: Text(
                            'Video',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        Text(
                          'Short Video',
                          style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ],
                    )),
                Positioned(
                    left: 10,
                    right: 10,
                    bottom: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Visibility(
                          visible: false,
                          child: GestureDetector(
                            onTap: () {
                              // pickImage();
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.2),
                              ),
                              child: pictureFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.file(File(pictureFile!.path),
                                          fit: BoxFit.fill))
                                  : Container(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            _toggleRecording();
                            changeState();
                          },
                          child: !isRecording
                              ? Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      border: Border.all(
                                          width: 5, color: Colors.white),
                                      shape: BoxShape.circle))
                              : Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 5, color: Colors.white),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.red),
                                    ),
                                  ),
                                ),
                        ),
                        GestureDetector(
                          onTap: () {
                            toggleCamera();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.black.withOpacity(0.2)),
                            child: Center(
                              child: FaIcon(FontAwesomeIcons.rotate,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            );
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     pictureFile = await controller.takePicture();
        //     print(pictureFile?.path.toString());
        //     setState(() {});
        //   },
        //   child: Icon(Icons.camera_alt),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget flashRow(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {
                flashClicked = false;
                flashIcon = Icon(Icons.flash_on, color: Colors.amber);
                isFlashOn = true;
                flashMode = FlashMode.torch;
                controller.setFlashMode(flashMode);
                changeState();
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: Icon(Icons.flash_on,
                    color: isFlashOn == true ? Colors.amber : Colors.white),
              )),
          GestureDetector(
              onTap: () {
                flashClicked = false;
                flashIcon = Icon(Icons.flash_auto, color: Colors.amber);
                isFlashOn = null;
                flashMode = FlashMode.auto;
                controller.setFlashMode(flashMode);
                changeState();
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: Icon(Icons.flash_auto,
                    color: isFlashOn == null ? Colors.amber : Colors.white),
              )),
          GestureDetector(
              onTap: () {
                flashClicked = false;
                flashIcon = Icon(Icons.flash_off, color: Colors.white);
                isFlashOn = false;
                flashMode = FlashMode.off;
                controller.setFlashMode(flashMode);
                changeState();
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: Icon(Icons.flash_off,
                    color: isFlashOn == false ? Colors.amber : Colors.white),
              )),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({required this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;

  XFile? pictureFile;
  int description = 0;
  bool isPhotoMode = true;
  bool frontCamera = true;

  bool? isFlashOn = false;
  bool flashClicked = false;
  FlashMode flashMode = FlashMode.auto;
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
      // final Directory appDir = await getApplicationSupportDirectory();
      // final String capturedPath =
      //     path.join(appDir.path, '${DateTime.now()}.jpg');

      await GallerySaver.saveImage(pictureFile!.path);
      // final File savedFile = File(pictureFile!.path);
      // await savedFile.rename(capturedPath);

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

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Camera'),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   elevation: 20,
      // ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
                child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller))),
            Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () async {
                        flashClicked = !flashClicked;
                        setState(() {});
                      },
                      child: flashClicked
                          ? flashRow()
                          : SizedBox(height: 50, width: 50, child: flashIcon)),
                  Visibility(
                    visible: flashClicked ? false : true,
                    child: GestureDetector(
                      onTap: () {
                        description = description == 0 ? 1 : 0;
                        startCamera(description);
                      },
                      child: FaIcon(
                        FontAwesomeIcons.qrcode,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
                        isPhotoMode = true;
                        changeState();
                      },
                      child: Text(
                        'Photo',
                        style: TextStyle(
                            color: isPhotoMode ? Colors.amber : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        isPhotoMode = false;
                        changeState();
                      },
                      child: Text(
                        'Video',
                        style: TextStyle(
                            color: isPhotoMode ? Colors.white : Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
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
                    GestureDetector(
                      onTap: () {
                        pickImage();
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
                    GestureDetector(
                      onTap: () {
                        captureImage();
                      },
                      child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              border: Border.all(width: 5, color: Colors.white),
                              shape: BoxShape.circle)),
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
        ),
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
    );
  }

  Widget flashRow() {
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

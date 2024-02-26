import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  XFile? pictureFile;
  int description = 0;
  @override
  void initState() {
    super.initState();
    startCamera(description);
  }

  void startCamera(int description) {
    controller = CameraController(
      widget.cameras![description],
      ResolutionPreset.max,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: Text('Camera'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: CameraPreview(controller),
                ),
              ),
            ),
            Row(
              children: [
                Spacer(),
                GestureDetector(
                  onTap: () {
                    description = description == 0 ? 1 : 0;
                    startCamera(description);
                  },
                  child: Container(
                      height: 50,
                      width: 50,
                      color: Color.fromARGB(255, 221, 190, 226),
                      child: Icon(Icons.flip_camera_android_outlined)),
                ),
                Spacer(),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            if (pictureFile != null)
              // Image.network(
              //   pictureFile!.path,
              //   height: 200,
              // )
              //Android/iOS
              SizedBox(
                height: 300,
                width: 300,
                child: Image.file(
                  File(pictureFile!.path),
                  fit: BoxFit.fill,
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          pictureFile = await controller.takePicture();
          print(pictureFile?.path.toString());
          setState(() {});
        },
        child: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

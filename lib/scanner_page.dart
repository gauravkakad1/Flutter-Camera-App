import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class MobileScannerPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const MobileScannerPage({required this.cameras, Key? key}) : super(key: key);

  @override
  State<MobileScannerPage> createState() => _MobileScannerPageState();
}

class _MobileScannerPageState extends State<MobileScannerPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Scan qr code'),
        centerTitle: true,
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.qr_code_scanner),
      ),
    ));
  }
}

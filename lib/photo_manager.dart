import 'dart:typed_data';

import 'package:camera_app/media_picker.dart';
import 'package:camera_app/media_services.dart';
import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

class PhotoManager extends StatefulWidget {
  const PhotoManager({super.key});

  @override
  State<PhotoManager> createState() => _PhotoManagerState();
}

class _PhotoManagerState extends State<PhotoManager> {
  List<AssetEntity> selectedAssetList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changeState();
  }

  void changeState() {
    if (mounted) {
      setState(() {});
    }
  }

  Future pickAssets({
    required int maxCount,
    required RequestType requestType,
  }) async {
    final result = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return MediaPicker(
          maxCount: maxCount,
          requestType: requestType,
        );
      },
    ));
    print(result.toString());
    if (result != null) {
      selectedAssetList = result;
      changeState();
    } else {
      selectedAssetList = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        elevation: 50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: GridView.builder(
          itemCount: selectedAssetList.length,
          physics: const BouncingScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, index) {
            print(selectedAssetList.length);
            AssetEntity assetEntity = selectedAssetList[index];
            return FutureBuilder<Uint8List?>(
              future: assetEntity.thumbnailData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: Image.memory(
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.error),
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error loading thumbnail: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickAssets(maxCount: 5, requestType: RequestType.all);
        },
        child: Icon(
          Icons.add_a_photo,
        ),
      ),
    ));
  }
}

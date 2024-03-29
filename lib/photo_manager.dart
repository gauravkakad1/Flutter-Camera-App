import 'dart:typed_data';

import 'package:camera_app/media_picker.dart';
import 'package:camera_app/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class PhotoManager extends StatefulWidget {
  const PhotoManager({super.key});

  @override
  State<PhotoManager> createState() => _PhotoManagerState();
}

class _PhotoManagerState extends State<PhotoManager> {
  @override
  void initState() {
    super.initState();
    Provider.of<MediaProvider>(context, listen: false)
        .loadAlbums(RequestType.all);
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
        body: Selector<MediaProvider, List<AssetEntity>>(
          selector: (context, provider) =>
              List.from(provider.selectedAssetList),
          builder: (context, selectedAssetList, child) {
            return GridView.builder(
              itemCount: selectedAssetList.length,
              physics: const BouncingScrollPhysics(),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
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
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Provider.of<MediaProvider>(context, listen: false)
                .clearSelectedAssets();
            // Navigate to the MediaPicker screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MediaPicker(
                        maxCount: 5, requestType: RequestType.image)));
          },
          child: Icon(Icons.add_a_photo),
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:camera_app/media_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaPicker extends StatefulWidget {
  final int maxCount;
  final RequestType requestType;
  const MediaPicker({
    super.key,
    required this.maxCount,
    required this.requestType,
  });

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedAssetList = [];
  void changeState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    MediaServices().loadAlbums(RequestType.all).then(
      (value) {
        albumList = value;
        selectedAlbum = value[0];
        changeState();
        MediaServices().loadAssets(selectedAlbum!).then(
          (value) {
            assetList = value;
            changeState();
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              title: DropdownButton<AssetPathEntity>(
                value: selectedAlbum,
                onChanged: (AssetPathEntity? value) {
                  selectedAlbum = value;
                  changeState();
                  MediaServices().loadAssets(selectedAlbum!).then(
                    (value) {
                      assetList = value;
                      changeState();
                    },
                  );
                },

                items: albumList.map<DropdownMenuItem<AssetPathEntity>>(
                    (AssetPathEntity album) {
                  return DropdownMenuItem(
                      value: album, child: Text('${album.name} '));
                }).toList(),
                // items: albumList.map<DropdownMenuItem<AssetPathEntity>>
                // (AssetPathEntity album){
                //   return DropdownMenuItem<AssetPathEntity>(value: album)
                // }.toList(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, selectedAssetList);
              },
              child: Icon(Icons.check),
            ),
            body: assetList.isEmpty
                ? const CircularProgressIndicator(
                    color: Colors.black,
                  )
                : GridView.builder(
                    itemCount: assetList.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      AssetEntity assetEntity = assetList[index];
                      return Center(
                        child: FutureBuilder<Uint8List?>(
                          future: _loadThumbnail(assetEntity: assetEntity),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              // Display the thumbnail using Image.memory
                              if (assetEntity.type == AssetType.image) {
                                return Padding(
                                  padding:
                                      selectedAssetList.contains(assetEntity)
                                          ? const EdgeInsets.all(8.0)
                                          : const EdgeInsets.all(3.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black)),
                                        height: 200,
                                        width: 200,
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _selectAsset(assetEntity),
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    selectedAssetList.contains(
                                                                assetEntity) ==
                                                            true
                                                        ? Colors.red
                                                        : Colors.transparent,
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.black)),
                                            child: Center(
                                              child: Text(
                                                selectedAssetList
                                                        .contains(assetEntity)
                                                    ? '${selectedAssetList.indexOf(assetEntity) + 1}'
                                                    : "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (assetEntity.type == AssetType.video) {
                                return Padding(
                                  padding:
                                      selectedAssetList.contains(assetEntity)
                                          ? const EdgeInsets.all(8.0)
                                          : const EdgeInsets.all(3.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black)),
                                        height: 200,
                                        width: 200,
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                          bottom: 10,
                                          right: 10,
                                          child: FaIcon(
                                            FontAwesomeIcons.video,
                                            color: Colors.red,
                                            size: 16,
                                          )),
                                      Positioned(
                                          left: 10,
                                          top: 10,
                                          child: FaIcon(
                                            FontAwesomeIcons.play,
                                            color: Colors.white,
                                            size: 16,
                                          )),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _selectAsset(assetEntity),
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    selectedAssetList.contains(
                                                                assetEntity) ==
                                                            true
                                                        ? Colors.red
                                                        : Colors.transparent,
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.black)),
                                            child: Center(
                                              child: Text(
                                                selectedAssetList
                                                        .contains(assetEntity)
                                                    ? '${selectedAssetList.indexOf(assetEntity) + 1}'
                                                    : "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container(
                                  child: Icon(Icons.error),
                                );
                              }
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Error loading thumbnail: ${snapshot.error}');
                            } else {
                              // Display a loading indicator while the thumbnail is being loaded
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  )));
  }

  Future<Uint8List?> _loadThumbnail({required AssetEntity assetEntity}) async {
    // Check the type before attempting to load the thumbnail
    if (assetEntity.type == AssetType.image ||
        assetEntity.type == AssetType.video) {
      return assetEntity.thumbnailData;
    } else {
      assetList.remove(assetEntity);
      return null; // Handle other types as needed
    }
  }

  void _selectAsset(AssetEntity assetEntity) {
    if (widget.maxCount - 1 == selectedAssetList.length) {
      Navigator.pop(context, selectedAssetList);
    }
    if (selectedAssetList.contains(assetEntity)) {
      _removeAsset(assetEntity);
    } else if (selectedAssetList.length < widget.maxCount) {
      _addAsset(assetEntity);
    }
  }

  void _addAsset(AssetEntity assetEntity) {
    selectedAssetList.insert(selectedAssetList.length, assetEntity);
    changeState();
  }

  void _removeAsset(AssetEntity assetEntity) {
    selectedAssetList.remove(assetEntity);
    changeState();
  }
}

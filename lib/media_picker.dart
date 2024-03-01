import 'dart:typed_data';

import 'package:camera_app/asset_widget.dart';
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
  int currentPage = 1;
  int pageSize = 50;
  bool isLoading = false;
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedAssetList = [];

  ScrollController _scrollController = ScrollController();

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
    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      loadMoreThumbnails();
    }
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
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, selectedAssetList);
              },
              child: Icon(Icons.check),
            ),
            body: assetList.isEmpty
                ? Center(
                    child: const CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          itemCount: assetList.length,
                          physics: const BouncingScrollPhysics(),
                          controller: _scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemBuilder: (context, index) {
                            if (index < assetList.length) {
                              AssetEntity assetEntity = assetList[index];
                              return Center(
                                child: FutureBuilder<Uint8List?>(
                                  future:
                                      _loadThumbnail(assetEntity: assetEntity),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      return AssetWidget(
                                        assetEntity: assetEntity,
                                        selectedAssetList: selectedAssetList,
                                        maxCount: widget.maxCount,
                                        snapshot: snapshot,
                                        onAssetSelectionChange:
                                            (List<AssetEntity> assetList) {
                                          selectedAssetList = assetList;
                                          changeState();
                                        },
                                      );
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
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      isLoading
                          ? CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : Container()
                    ],
                  )));
  }

  Future<Uint8List?> _loadThumbnail({required AssetEntity assetEntity}) async {
    if (assetEntity.type == AssetType.image ||
        assetEntity.type == AssetType.video) {
      return assetEntity.thumbnailData;
    } else {
      return null;
    }
  }

  void loadMoreThumbnails() async {
    isLoading = true;
    changeState();
    print(
        '***********************************************\nloading more data \n************************************************************');

    try {
      currentPage++;
      List<AssetEntity> moreAssets = await MediaServices().loadAssets(
        selectedAlbum!,
        page: currentPage,
        pageSize: pageSize,
      );
      assetList.addAll(moreAssets);
      isLoading = false;
      changeState();
    } catch (e) {
      print(e);
    }
    // finally {
    //   isLoading = false;
    //   changeState();
    // }
  }
  // void _selectAsset(AssetEntity assetEntity) {
  //   if (selectedAssetList.contains(assetEntity)) {
  //     _removeAsset(assetEntity);
  //   } else if (selectedAssetList.length < widget.maxCount) {
  //     _addAsset(assetEntity);
  //   } else if (widget.maxCount == selectedAssetList.length) {
  //     Navigator.pop(context, selectedAssetList);
  //   }
  // }

  // void _addAsset(AssetEntity assetEntity) {
  //   selectedAssetList.insert(selectedAssetList.length, assetEntity);
  //   changeState();
  // }

  // void _removeAsset(AssetEntity assetEntity) {
  //   selectedAssetList.remove(assetEntity);
  //   changeState();
  // }
}

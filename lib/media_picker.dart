import 'dart:typed_data';

import 'package:camera_app/asset_widget.dart';
import 'package:camera_app/media_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

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
  void changeState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    final p = Provider.of<MediaServices>(context, listen: false);
    p.loadAlbums(RequestType.all).then(
      (value) {
        p.albumList = value;
        p.selectedAlbum = value[0];
        // changeState();
        p.loadAssets(p.selectedAlbum!).then(
          (value) {
            p.assetList = value;
            // changeState();
          },
        );
      },
    );
    p.scrollController.addListener(p.scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaServices>(context, listen: false);

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              title: DropdownButton<AssetPathEntity>(
                value: provider.selectedAlbum,
                onChanged: (AssetPathEntity? value) {
                  provider.selectedAlbum = value;
                  changeState();
                  provider.loadAssets(provider.selectedAlbum!).then(
                    (value) {
                      provider.assetList = value;
                      changeState();
                    },
                  );
                },
                items: provider.albumList
                    .map<DropdownMenuItem<AssetPathEntity>>(
                        (AssetPathEntity album) {
                  return DropdownMenuItem(
                      value: album, child: Text('${album.name} '));
                }).toList(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, provider.selectedAssetList);
              },
              child: Icon(Icons.check),
            ),
            body: provider.assetList.isEmpty
                ? Center(
                    child: const CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : Column(
                    children: [
                      Consumer<MediaServices>(
                        builder: (context, value, child) {
                          return Expanded(
                            child: GridView.builder(
                              itemCount: provider.assetList.length,
                              physics: const BouncingScrollPhysics(),
                              controller: provider.scrollController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3),
                              itemBuilder: (context, index) {
                                if (index < provider.assetList.length) {
                                  AssetEntity assetEntity =
                                      provider.assetList[index];
                                  return Center(
                                    child: FutureBuilder<Uint8List?>(
                                      future: provider.loadThumbnail(
                                          assetEntity: assetEntity),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return AssetWidget(
                                            assetEntity: assetEntity,
                                            selectedAssetList:
                                                provider.selectedAssetList,
                                            maxCount: widget.maxCount,
                                            snapshot: snapshot,
                                            onAssetSelectionChange:
                                                (List<AssetEntity> assetList) {
                                              provider.selectedAssetList =
                                                  assetList;
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
                          );
                        },
                      ),
                      provider.isLoading
                          ? CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : Container()
                    ],
                  )));
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

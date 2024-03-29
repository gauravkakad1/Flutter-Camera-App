import 'package:camera_app/asset_widget.dart';
import 'package:camera_app/media_provider.dart';
import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<MediaProvider>().loadNextAssetPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Selector<MediaProvider, List<AssetPathEntity>>(
            selector: (context, provider) => provider.albumList,
            builder: (context, albumList, child) {
              print('Album list: ${albumList.length}');
              return DropdownButton<AssetPathEntity>(
                value: context.select<MediaProvider, AssetPathEntity>((value) {
                  if (value.selectedAlbum == null) {
                    throw StateError('selectedAlbum is null');
                  }
                  return value.selectedAlbum!;
                }),
                onChanged: (AssetPathEntity? value) {
                  context.read<MediaProvider>().selectAlbum(value!);
                },
                items: albumList.map<DropdownMenuItem<AssetPathEntity>>(
                  (AssetPathEntity album) {
                    return DropdownMenuItem(
                      value: album,
                      child: Text('${album.name}'),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.check),
        ),
        body: Selector<MediaProvider, List<AssetEntity>>(
          selector: (context, provider) => List.from(provider.assetList),
          builder: (context, assetList, child) {
            return assetList.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: assetList.length,
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      AssetEntity assetEntity = assetList[index];
                      return AssetWidget(
                        assetEntity: assetEntity,
                        maxCount: widget.maxCount,
                        onAssetSelected: (asset) {
                          context.read<MediaProvider>().selectAsset(asset);
                        },
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}

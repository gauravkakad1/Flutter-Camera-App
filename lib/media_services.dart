import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaServices extends ChangeNotifier {
  int currentPage = 1;
  int pageSize = 50;
  bool isLoading = false;
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedAssetList = [];

  ScrollController scrollController = ScrollController();
  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMoreThumbnails();
      notifyListeners();
    }
  }

  Future<Uint8List?> loadThumbnail({required AssetEntity assetEntity}) async {
    if (assetEntity.type == AssetType.image ||
        assetEntity.type == AssetType.video) {
      return assetEntity.thumbnailData;
    } else {
      return null;
    }
  }

  void loadMoreThumbnails() async {
    isLoading = true;
    notifyListeners();
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
      // notifyListeners();
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  Future loadAlbums(RequestType requestType) async {
    var permission = await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> albumList = [];
    if (permission.isAuth == true) {
      albumList = await PhotoManager.getAssetPathList(
        type: requestType,
      );
    } else {
      PhotoManager.openSetting();
    }
    return albumList;
  }

  Future<List<AssetEntity>> loadAssets(AssetPathEntity selectedAlbum,
      {int page = 1, int pageSize = 50}) async {
    int start = (page - 1) * pageSize;
    int end = start + pageSize;
    int totalAssets = await selectedAlbum.assetCountAsync;

    if (totalAssets <= start) return [];
    if (end > totalAssets) end = totalAssets;
    List<AssetEntity> assetList =
        await selectedAlbum.getAssetListRange(start: start, end: end);
    return assetList;
  }
}

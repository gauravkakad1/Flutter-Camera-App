import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaServices {
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

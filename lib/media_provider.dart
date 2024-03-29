import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaProvider extends ChangeNotifier {
  List<AssetEntity> _selectedAssetList = [];
  List<AssetPathEntity> _albumList = [];
  AssetPathEntity? _selectedAlbum;
  List<AssetEntity> _assetList = [];
  int _currentPage = 0;
  final int _assetsPerPage = 50;

  List<AssetEntity> get selectedAssetList => _selectedAssetList;
  List<AssetPathEntity> get albumList => _albumList;
  AssetPathEntity? get selectedAlbum => _selectedAlbum;
  List<AssetEntity> get assetList => _assetList;

  void selectAsset(AssetEntity asset) {
    if (_selectedAssetList.contains(asset)) {
      _selectedAssetList.remove(asset);
    } else {
      _selectedAssetList.add(asset);
    }
    notifyListeners();
  }

  void toggleAssetSelection(AssetEntity asset) {
    if (_selectedAssetList.contains(asset)) {
      _selectedAssetList.remove(asset);
    } else {
      _selectedAssetList.add(asset);
    }
    notifyListeners();
  }

  void clearSelectedAssets() {
    _selectedAssetList.clear();
    notifyListeners();
  }

  int getIndexForAsset(AssetEntity asset) {
    int index = _selectedAssetList.indexOf(asset);
    return index != -1 ? index + 1 : 0;
  }

  void selectAlbum(AssetPathEntity album) async {
    _selectedAlbum = album;
    _currentPage = 0;
    _assetList = await album.getAssetListRange(start: 0, end: _assetsPerPage);
    notifyListeners();
  }

  Future<void> loadNextAssetPage() async {
    if (_selectedAlbum != null) {
      int start = (_currentPage + 1) * _assetsPerPage;
      int end = start + _assetsPerPage;
      List<AssetEntity> nextAssets =
          await _selectedAlbum!.getAssetListRange(start: start, end: end);
      _assetList.addAll(nextAssets);
      _currentPage++;
      notifyListeners();
    }
  }

  Future<void> loadAlbums(RequestType requestType) async {
    var permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      _albumList = await PhotoManager.getAssetPathList(type: requestType);
      if (_albumList.isNotEmpty) {
        _selectedAlbum = _albumList.first;
        _assetList = await _selectedAlbum!
            .getAssetListRange(start: 0, end: _assetsPerPage);
      }
    } else {
      PhotoManager.openSetting();
    }
    notifyListeners();
  }
}

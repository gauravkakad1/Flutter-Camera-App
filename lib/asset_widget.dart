import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetWidget extends StatefulWidget {
  final AssetEntity assetEntity;
  final List<AssetEntity> selectedAssetList;
  final int maxCount;
  final AsyncSnapshot<Uint8List?> snapshot;
  final Function(List<AssetEntity>) onAssetSelectionChange;
  const AssetWidget(
      {super.key,
      required this.assetEntity,
      required this.selectedAssetList,
      required this.maxCount,
      required this.snapshot,
      required this.onAssetSelectionChange});

  @override
  State<AssetWidget> createState() => _AssetWidgetState();
}

class _AssetWidgetState extends State<AssetWidget> {
  late List<AssetEntity> assetList;
  void changeState() {
    if (mounted) {
      print('change state');
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    assetList = widget.selectedAssetList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: assetList.contains(widget.assetEntity)
          ? const EdgeInsets.all(8.0)
          : const EdgeInsets.all(3.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            height: 200,
            width: 200,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Image.memory(
                widget.snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Visibility(
            visible: widget.assetEntity.type == AssetType.video,
            child: Positioned(
                bottom: 10,
                right: 10,
                child: FaIcon(
                  FontAwesomeIcons.video,
                  color: Colors.red,
                  size: 16,
                )),
          ),
          Visibility(
            visible: widget.assetEntity.type == AssetType.video,
            child: Positioned(
                left: 10,
                top: 10,
                child: FaIcon(
                  FontAwesomeIcons.play,
                  color: Colors.white,
                  size: 16,
                )),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => _selectAsset(widget.assetEntity),
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: assetList.contains(widget.assetEntity) == true
                        ? Colors.blue
                        : Colors.transparent,
                    border: Border.all(width: 1, color: Colors.black)),
                child: Center(
                  child: Text(
                    assetList.contains(widget.assetEntity)
                        ? '${assetList.indexOf(widget.assetEntity) + 1}'
                        : "",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAsset(AssetEntity assetEntity) {
    if (assetList.contains(assetEntity)) {
      _removeAsset(assetEntity);
    } else if (assetList.length < widget.maxCount) {
      _addAsset(assetEntity);
      if (widget.maxCount == assetList.length) {
        Navigator.pop(context, assetList);
      }
    }
  }

  void _addAsset(AssetEntity assetEntity) {
    assetList.insert(assetList.length, assetEntity);
    changeState();
  }

  void _removeAsset(AssetEntity assetEntity) {
    widget.onAssetSelectionChange(assetList);
    assetList.remove(assetEntity);
    changeState();
  }
}

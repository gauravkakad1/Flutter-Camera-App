import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';

// class AssetWidget extends StatelessWidget {
//   final AssetEntity assetEntity;
//   final int maxCount;
//   final Function(AssetEntity) onAssetSelected;

//   const AssetWidget({
//     super.key,
//     required this.assetEntity,
//     required this.maxCount,
//     required this.onAssetSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(3.0),
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(border: Border.all(color: Colors.black)),
//             height: 200,
//             width: 200,
//             child: Padding(
//               padding: const EdgeInsets.all(3.0),
//               child: FutureBuilder<Uint8List?>(
//                 future: _loadThumbnail(assetEntity: assetEntity),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//                     return Image.memory(
//                       snapshot.data!,
//                       fit: BoxFit.cover,
//                     );
//                   } else if (snapshot.hasError) {
//                     return Text('Error loading thumbnail: ${snapshot.error}');
//                   } else {
//                     return CircularProgressIndicator();
//                   }
//                 },
//               ),
//             ),
//           ),
//           Visibility(
//             visible: assetEntity.type == AssetType.video,
//             child: Positioned(
//               bottom: 10,
//               right: 10,
//               child: FaIcon(
//                 FontAwesomeIcons.video,
//                 color: Colors.red,
//                 size: 16,
//               ),
//             ),
//           ),
//           Visibility(
//             visible: assetEntity.type == AssetType.video,
//             child: Positioned(
//               left: 10,
//               top: 10,
//               child: FaIcon(
//                 FontAwesomeIcons.play,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//           ),
//           Positioned(
//             top: 10,
//             right: 10,
//             child: GestureDetector(
//               onTap: () => onAssetSelected(assetEntity),
//               child: Container(
//                 height: 30,
//                 width: 30,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(width: 1, color: Colors.black),
//                 ),
//                 child: Center(
//                   child: Icon(
//                     Icons.check,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   Future<Uint8List?> _loadThumbnail({required AssetEntity assetEntity}) async {
//   if (assetEntity.type == AssetType.image ||
//       assetEntity.type == AssetType.video) {
//     return assetEntity.thumbnailData;
//   } else {
//     // Return null or a placeholder thumbnail
//     return null;
//   }
// }
// }
import 'dart:typed_data';
import 'package:camera_app/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class AssetWidget extends StatelessWidget {
  final AssetEntity assetEntity;
  final int maxCount;
  final Function(AssetEntity) onAssetSelected;

  const AssetWidget(
      {super.key,
      required this.assetEntity,
      required this.maxCount,
      required this.onAssetSelected});

  ValueNotifier<bool> _valueNotifierForAsset(BuildContext context) {
    final provider = context.read<MediaProvider>();
    final isSelected = provider.selectedAssetList.contains(assetEntity);
    return ValueNotifier<bool>(isSelected);
  }

  @override
  Widget build(BuildContext context) {
    // print('Building asset widget for ${assetEntity.id}');
    final provider = context.read<MediaProvider>();
    final isSelected = provider..selectedAssetList.contains(assetEntity);
    return Selector<MediaProvider, bool>(
      selector: (_, provider) =>
          provider.selectedAssetList.contains(assetEntity),
      builder: (context, isSelected, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _valueNotifierForAsset(context),
          builder: (context, isSelected, child) {
            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: Stack(
                key: ValueKey(assetEntity),
                children: [
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    height: 200,
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: FutureBuilder<Uint8List?>(
                        future: _loadThumbnail(assetEntity: assetEntity),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                                'Error loading thumbnail: ${snapshot.error}');
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: assetEntity.type == AssetType.video,
                    child: Positioned(
                      bottom: 10,
                      right: 10,
                      child: FaIcon(
                        FontAwesomeIcons.video,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: assetEntity.type == AssetType.video,
                    child: Positioned(
                      left: 10,
                      top: 10,
                      child: FaIcon(
                        FontAwesomeIcons.play,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        provider.toggleAssetSelection(assetEntity);
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.blue : Colors.transparent,
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: Center(
                          child: isSelected
                              ? Text(
                                  '${provider.getIndexForAsset(assetEntity)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Uint8List?> _loadThumbnail({required AssetEntity assetEntity}) async {
    if (assetEntity.type == AssetType.image ||
        assetEntity.type == AssetType.video) {
      return assetEntity.thumbnailData;
    } else {
      return null;
    }
  }
}

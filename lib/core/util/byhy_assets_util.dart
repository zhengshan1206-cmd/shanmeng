
import 'dart:io';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ByAssetsUtil {
  static Future<String> filePathForAsset(dynamic asset) async {
    if (asset is File) {
      return asset.path;
    } else if (asset is AssetEntity) {
      final file = await asset.file;
      return file?.path ?? "";
    } else {
      return "";
    }
  }

  static Future<AssetEntity?> getAssetEntityByName(String imageName) async {

    /// 获取所有相册路径
    List<AssetPathEntity> albums =
    await PhotoManager.getAssetPathList(onlyAll: true);

    for (AssetPathEntity album in albums) {
      final count = await album.assetCountAsync;
      /// 获取相册中的所有资源
      List<AssetEntity> assets =
      await album.getAssetListRange(start: 0, end: count);

      /// 查找与图片名匹配的资源
      for (AssetEntity asset in assets) {
        if (asset.title?.toLowerCase() == imageName.toLowerCase()) {
          return asset; /// 找到匹配的资源
        }
      }
    }

    return null; /// 未找到匹配的资源
  }

  static Future<AssetEntity?> getAssetEntityByPath(String filePath) async {
    /// 获取所有相册路径
    List<AssetPathEntity> albums =
    await PhotoManager.getAssetPathList(onlyAll: true);

    for (AssetPathEntity album in albums) {
      final count = await album.assetCountAsync;
      /// 获取相册中的所有资源
      List<AssetEntity> assets =
      await album.getAssetListRange(start: 0, end: count);

      /// 查找与图片名匹配的资源
      for (AssetEntity asset in assets) {
        final file = await asset.file;
        if (file != null && file.path == filePath) {
          return asset; // 找到匹配的资源
        }
      }
    }

    return null; /// 未找到匹配的资源
  }
}

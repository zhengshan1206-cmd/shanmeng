/*
 * @Author: duncy
 * @Date: 2026-04-10 13:56:22
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-10 17:42:50
 * @FilePath: /ling_bao/lib/profile/record/controller/record_detail_controller.dart
 * @Description: 
 */
import 'package:get/get.dart';
import 'package:ling_bao/core/service/app_permisson/byhy_permission_utils.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';
import 'package:ling_bao/core/util/byhy_download_util.dart';
import '../../../video/shared/home_models.dart';
import '../../integral/bean/video_works_bean.dart';
import '../../main/bean/ai_draw_img_details_bean.dart';

class RecordDetailController extends GetxController {
  CreationMode mode = .image;
  String url = '';
  String videoCoverUrl = '';
  AiDrawImgDetailsBean? imageItem;
  VideoWorksBean? videoItem;

  @override
  void onInit() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      mode = args['mode'] ?? .image;
      final item = args['item'];
      if (mode == .image && item is AiDrawImgDetailsBean) {
        imageItem = item;
        url = item.picUrl;
      } else if (mode == .video && item is VideoWorksBean) {
        videoItem = item;
        url = item.videoUrl;
        videoCoverUrl = item.coverUrl;
      }
    }
    super.onInit();
  }

  Future<void> saveToPhone() async {
    if (url.isEmpty) {
      Toast.showText(text: '资源地址为空');
      return;
    }

    if (mode == CreationMode.image) {
      final imageUrl = imageItem?.picUrl ?? '';
      if (imageUrl.isEmpty) {
        Toast.showText(text: '图片地址为空');
        return;
      }
      await ByDownloadUtil.saveNetwrokImage(imageUrl);
      return;
    }

    final videoUrl = videoItem?.videoUrl ?? '';
    if (videoUrl.isEmpty) {
      Toast.showText(text: '视频地址为空');
      return;
    }
    final granted = await ByPermissionUtils.appStorage();
    if (!granted) return;

    final fileName = _guessFileName(videoUrl, defaultExt: 'mp4');
    await ByDownloadUtil.downloadVideo(
      videoUrl,
      fileName,
      showLoading: true,
      onSuccess: (filePath) async {
        await ByDownloadUtil.saveVideoToAlbum(
          filePath,
          fileName: fileName,
          isToast: true,
        );
      },
    );
  }

  String _guessFileName(String url, {required String defaultExt}) {
    try {
      final uri = Uri.parse(url);
      final last = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (last.isNotEmpty && last.contains('.')) return last;
      return '${DateTime.now().millisecondsSinceEpoch}.$defaultExt';
    } catch (_) {
      final parts = url.split('/').where((e) => e.isNotEmpty).toList();
      final last = parts.isNotEmpty ? parts.last : '';
      if (last.isNotEmpty && last.contains('.')) return last;
      return '${DateTime.now().millisecondsSinceEpoch}.$defaultExt';
    }
  }
}

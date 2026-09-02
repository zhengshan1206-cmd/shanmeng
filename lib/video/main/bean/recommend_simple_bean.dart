/*
 * @Author: duncy
 * @Date: 2026-05-09 15:46:07
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-09 16:23:39
 * @FilePath: /ling_bao/lib/video/main/bean/recommend_simple_bean.dart
 * @Description: 
 */
class RecommendSimpleBean {
  int id;
  int categoryID;
  bool isVideo;
  String? coverUrl;
  String? previewCoverUrl;
  String? sourceVideoUrl;
  String? previewVideoUrl;
  String? prompt;
  String? title;

  RecommendSimpleBean({
    required this.id,
    required this.categoryID,
    required this.isVideo,
    this.coverUrl,
    this.previewCoverUrl,
    this.previewVideoUrl,
    this.sourceVideoUrl,
    this.prompt,
    this.title,
  });

  factory RecommendSimpleBean.fromJson(Map<String, dynamic> json) {
    return RecommendSimpleBean(
      id: json['id'],
      categoryID: json['category_id'],
      isVideo: json['template_source'] == 'video',
      title: json['title'],
      prompt: json['prompt'],
      coverUrl:
          json['template']['pic_url'] ?? json['template']['source_cover_url'],
      previewCoverUrl:
          json['template']['mini_pic_url'] ??
          json['template']['preview_cover_url'],
      sourceVideoUrl: json['template']['source_video_url'] ?? '',
      previewVideoUrl: json['template']['preview_video_url'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {};
  }
}

/*
 * @Author: duncy
 * @Date: 2026-04-14 09:06:16
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-14 17:48:20
 * @FilePath: /ling_bao/lib/profile/main/bean/ai_draw_img_details_bean.dart
 * @Description: 
 */

class AiDrawImgDetailsBean {
  int id;
  int status;
  String prompt;
  String picUrl;
  String? thumbUrl;
  int modelId;
  String ratio;
  String model;
  String userName;
  String userAvatar;
  String? useTime;
  String? withdrawMoney;
  String? withdrawMoneyTip;
  int? createDays;
  String? createAt;
  String? title;
  int? generateType;
  String? previewVideoUrl;
  AiDrawImgDetailsBean({
    required this.id,
    required this.status,
    required this.prompt,
    required this.picUrl,
    this.thumbUrl,
    required this.modelId,
    required this.ratio,
    required this.model,
    required this.userName,
    required this.userAvatar,
    this.useTime,
    this.withdrawMoney,
    this.createDays,
    this.withdrawMoneyTip,
    this.createAt,
    this.title,
    this.generateType,
    this.previewVideoUrl,
  });

  bool get hasPreviewVideo {
    final String url = (previewVideoUrl ?? '').trim();
    if (url.isEmpty) return false;
    final String lower = url.toLowerCase();
    return lower != 'null' && lower != 'undefined';
  }

  String get normalizedPreviewVideoUrl =>
      hasPreviewVideo ? (previewVideoUrl ?? '').trim() : '';

  String get displayTitle {
    final String rawTitle = (title ?? '').trim();
    if (rawTitle.isNotEmpty) {
      return rawTitle;
    }
    return prompt;
  }

  /// 1 文生图 / 2 图生图；兼容接口返回 int、double、字符串
  static int? parseGenerateType(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  factory AiDrawImgDetailsBean.fromJson(Map<String, dynamic> json) =>
      AiDrawImgDetailsBean(
        id: json["id"],
        status: json["status"],
        prompt: json["prompt"],
        thumbUrl: json["mini_pic_url"],
        picUrl: json["pic_url"],
        ratio: json["ratio"],
        modelId: json["model_id"],
        model: json["model"],
        userName: json["active_user_name"],
        userAvatar: json["active_user_avatar"],
        useTime: json["use_time"],
        withdrawMoney: json["withdraw_money"],
        createDays: json["active_user_create_days"],
        withdrawMoneyTip: json["withdraw_money_tip"],
        createAt: json["create_at"],
        title: json["title"],
        generateType: parseGenerateType(
          json["generate_type"] ?? json["generateType"],
        ),
        previewVideoUrl: json["preview_video_url"],
      );
}

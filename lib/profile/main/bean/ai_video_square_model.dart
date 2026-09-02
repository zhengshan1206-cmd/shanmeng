import 'dart:convert';

enum AiVideoGenerationType {
  textToVideo(1),
  imageToVideo(2),
  embraceVideo(3),
  firstAndEndFrame(52),
  multipleImages(53);

  final int code;
  const AiVideoGenerationType(this.code);

  factory AiVideoGenerationType.fromJson(int json) =>
      AiVideoGenerationType.fromDynamic(json);

  /// 同款列表历史上同时出现过 5/6 和 52/53 两套码值，这里统一收口，
  /// 避免模板下发格式切换时影响同款流程和权益判断。
  static AiVideoGenerationType fromDynamic(dynamic value) {
    final int? code = _parseAiVideoGenerationTypeCode(value);
    switch (code) {
      case 1:
        return AiVideoGenerationType.textToVideo;
      case 2:
        return AiVideoGenerationType.imageToVideo;
      case 3:
        return AiVideoGenerationType.embraceVideo;
      case 5:
      case 52:
        return AiVideoGenerationType.firstAndEndFrame;
      case 6:
      case 53:
        return AiVideoGenerationType.multipleImages;
      default:
        return AiVideoGenerationType.imageToVideo;
    }
  }
}

class AiVideoSquareModel {
  int userId;
  AiVideoGenerationType type;
  String? title;
  String userName;
  String? prompt;
  String? negativePrompt;
  String useTime;
  String withdrawMoney;
  String categoryIds;
  List<String>? labels;
  List<String>? multiImage;
  String? bgmUrl;
  String? imageTail;
  double cfgScale;
  String mode;
  String aspectRatio;
  String videoUrl;
  String coverUrl;
  String shareVideoUrl;
  String shareCoverUrl;
  String withdrawMoneyTip;
  String activeUserName;
  String activeUserAvatar;
  int activeUserCreateDays;

  AiVideoSquareModel({
    required this.userId,
    required this.type,
    this.title,
    required this.userName,
    required this.prompt,
    required this.negativePrompt,
    required this.useTime,
    required this.withdrawMoney,
    required this.categoryIds,
    required this.labels,
    required this.multiImage,
    this.bgmUrl,
    this.imageTail,
    required this.cfgScale,
    required this.mode,
    required this.aspectRatio,
    required this.videoUrl,
    required this.coverUrl,
    required this.shareVideoUrl,
    required this.shareCoverUrl,
    required this.withdrawMoneyTip,
    required this.activeUserName,
    required this.activeUserAvatar,
    required this.activeUserCreateDays,
  });

  AiVideoSquareModel copyWith({
    int? userId,
    AiVideoGenerationType? type,
    String? title,
    String? userName,
    String? prompt,
    String? negativePrompt,
    String? useTime,
    String? withdrawMoney,
    String? categoryIds,
    List<String>? labels,
    List<String>? multiImage,
    String? bgmUrl,
    String? imageTail,
    double? cfgScale,
    String? mode,
    String? aspectRatio,
    String? videoUrl,
    String? coverUrl,
    String? shareVideoUrl,
    String? shareCoverUrl,
    String? withdrawMoneyTip,
    String? activeUserName,
    String? activeUserAvatar,
    int? activeUserCreateDays,
  }) {
    return AiVideoSquareModel(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      userName: userName ?? this.userName,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      useTime: useTime ?? this.useTime,
      withdrawMoney: withdrawMoney ?? this.withdrawMoney,
      categoryIds: categoryIds ?? this.categoryIds,
      labels: labels ?? this.labels,
      multiImage: multiImage ?? this.multiImage,
      imageTail: imageTail ?? this.imageTail,
      bgmUrl: bgmUrl ?? this.bgmUrl,
      cfgScale: cfgScale ?? this.cfgScale,
      mode: mode ?? this.mode,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      videoUrl: videoUrl ?? this.videoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      shareVideoUrl: shareVideoUrl ?? this.shareVideoUrl,
      shareCoverUrl: shareCoverUrl ?? this.shareCoverUrl,
      withdrawMoneyTip: withdrawMoneyTip ?? this.withdrawMoneyTip,
      activeUserName: activeUserName ?? this.activeUserName,
      activeUserAvatar: activeUserAvatar ?? this.activeUserAvatar,
      activeUserCreateDays: activeUserCreateDays ?? this.activeUserCreateDays,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user_id': userId,
    'type': type.code,
    'title': title,
    'user_name': userName,
    'prompt': prompt,
    'negative_prompt': negativePrompt,
    'use_time': useTime,
    'withdraw_money': withdrawMoney,
    'category_ids': categoryIds,
    'labels': labels,
    'multi_image': multiImage,
    'bgm_url': bgmUrl,
    'image_tail': imageTail,
    'cfg_scale': cfgScale,
    'mode': mode,
    'aspect_ratio': aspectRatio,
    'video_url': videoUrl,
    'cover_url': coverUrl,
    'share_video_url': shareVideoUrl,
    'share_cover_url': shareCoverUrl,
    'withdraw_money_tip': withdrawMoneyTip,
    'active_user_name': activeUserName,
    'active_user_avatar': activeUserAvatar,
    'active_user_create_days': activeUserCreateDays,
  };
  factory AiVideoSquareModel.fromJson(Map<String, dynamic> json) =>
      AiVideoSquareModel(
        userId: _parseAiVideoSquareInt(json['user_id']),
        type: AiVideoGenerationType.fromDynamic(json['type']),
        title: _parseAiVideoSquareNullableString(
          json['title'] ?? json['template_name'],
        ),
        userName: _parseAiVideoSquareString(json['user_name']),
        prompt: _parseAiVideoSquareNullableString(json['prompt']),
        negativePrompt: _parseAiVideoSquareNullableString(
          json['negative_prompt'],
        ),
        useTime: _parseAiVideoSquareString(json['use_time']),
        withdrawMoney: _parseAiVideoSquareString(json['withdraw_money']),
        categoryIds: _parseAiVideoSquareString(json['category_ids']),
        labels: _parseAiVideoSquareStringList(json['labels']),
        multiImage: _parseAiVideoSquareStringList(json['multi_image']),
        bgmUrl: _parseAiVideoSquareNullableString(json['bgm_url']),
        imageTail: _parseAiVideoSquareNullableString(json['image_tail']),
        cfgScale: _parseAiVideoSquareDouble(json['cfg_scale']),
        mode: _parseAiVideoSquareString(json['mode']),
        aspectRatio: _parseAiVideoSquareString(json['aspect_ratio']),
        videoUrl: _parseAiVideoSquareString(json['video_url']),
        coverUrl: _parseAiVideoSquareString(json['cover_url']),
        shareVideoUrl: _parseAiVideoSquareString(json['share_video_url']),
        shareCoverUrl: _parseAiVideoSquareString(json['share_cover_url']),
        withdrawMoneyTip: _parseAiVideoSquareString(json['withdraw_money_tip']),
        activeUserName: _parseAiVideoSquareString(json['active_user_name']),
        activeUserAvatar: _parseAiVideoSquareString(json['active_user_avatar']),
        activeUserCreateDays: _parseAiVideoSquareInt(
          json['active_user_create_days'],
        ),
      );

  factory AiVideoSquareModel.fromRawJson(String str) =>
      AiVideoSquareModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

int? _parseAiVideoGenerationTypeCode(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

int _parseAiVideoSquareInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

double _parseAiVideoSquareDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

String _parseAiVideoSquareString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _parseAiVideoSquareNullableString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

List<String> _parseAiVideoSquareStringList(dynamic value) {
  if (value == null) return <String>[];
  if (value is List) {
    return value
        .where((element) => element != null)
        .map((element) => element.toString())
        .toList();
  }
  return <String>[value.toString()];
}

// To parse this JSON data, do
//
//     final videoFaceFusionTemplateBean = videoFaceFusionTemplateBeanFromJson(jsonString);

import 'dart:convert';

import 'package:ling_bao/profile/main/bean/ai_video_square_model.dart';

VideoFaceFusionTemplateBean videoFaceFusionTemplateBeanFromJson(String str) =>
    VideoFaceFusionTemplateBean.fromJson(json.decode(str));

String videoFaceFusionTemplateBeanToJson(VideoFaceFusionTemplateBean data) =>
    json.encode(data.toJson());

class VideoFaceFusionTemplateBean {
  int id;
  String title;
  String templateType;
  String prompt;
  String sourceAudioUrl;
  String sourceCoverUrl;
  String sourceVideoUrl;
  String previewCoverUrl;
  String previewVideoUrl;
  String miniPreviewVideoUrl;
  String sourceDuration;

  VideoFaceFusionTemplateBean({
    required this.id,
    required this.title,
    required this.templateType,
    required this.prompt,
    required this.sourceAudioUrl,
    required this.sourceCoverUrl,
    required this.sourceVideoUrl,
    required this.previewCoverUrl,
    required this.previewVideoUrl,
    required this.miniPreviewVideoUrl,
    required this.sourceDuration,
  });

  factory VideoFaceFusionTemplateBean.fromJson(Map<String, dynamic> json) =>
      VideoFaceFusionTemplateBean(
        id: _parseTemplateInt(json["id"]),
        title: _parseTemplateString(
          json["title"] ?? json["template_name"] ?? json["prompt"],
        ),
        templateType: _parseTemplateString(
          json["template_type"] ?? json["templateType"],
        ),
        prompt: _parseTemplateString(json["prompt"] ?? json["title"]),
        sourceAudioUrl: _parseTemplateString(json["source_audio_url"]),
        sourceCoverUrl: _parseTemplateString(
          json["source_cover_url"] ?? json["preview_cover_url"],
        ),
        sourceVideoUrl: _parseTemplateString(
          json["source_video_url"] ?? json["preview_video_url"],
        ),
        previewCoverUrl: _parseTemplateString(
          json["preview_cover_url"] ?? json["source_cover_url"],
        ),
        previewVideoUrl: _parseTemplateString(
          json["preview_video_url"] ?? json["source_video_url"],
        ),
        sourceDuration: _parseTemplateString(
          json["source_duration"] ?? json["duration"] ?? json["use_time"],
        ),
        miniPreviewVideoUrl: _parseTemplateString(
          json["mini_preview_video_url"],
        ),
      );

  factory VideoFaceFusionTemplateBean.fromLegacyModel(
    AiVideoSquareModel model,
  ) => VideoFaceFusionTemplateBean(
    id: 0,
    title: _parseTemplateString(model.prompt),
    templateType: _legacyTemplateRightsType(model.type),
    prompt: _parseTemplateString(model.prompt),
    sourceAudioUrl: _parseTemplateString(model.bgmUrl),
    sourceCoverUrl: model.coverUrl,
    sourceVideoUrl: model.videoUrl,
    previewCoverUrl: model.shareCoverUrl.isNotEmpty
        ? model.shareCoverUrl
        : model.coverUrl,
    previewVideoUrl: model.shareVideoUrl.isNotEmpty
        ? model.shareVideoUrl
        : model.videoUrl,
    sourceDuration: model.useTime,
    miniPreviewVideoUrl: '',
  );

  /// “创作同款”页仍复用旧的视频预览卡数据结构，这里只做最小桥接，
  /// 不改变真正的模板任务提交参数。
  AiVideoSquareModel toLegacyModel() => AiVideoSquareModel(
    userId: 0,
    type: _legacyVideoType(templateType),
    userName: '',
    prompt: prompt.isNotEmpty ? prompt : title,
    negativePrompt: '',
    useTime: sourceDuration,
    withdrawMoney: '',
    categoryIds: '',
    labels: const <String>[],
    multiImage: const <String>[],
    bgmUrl: sourceAudioUrl,
    imageTail: null,
    cfgScale: 0.5,
    mode: 'std',
    aspectRatio: '4:3',
    videoUrl: previewVideoUrl.isNotEmpty ? previewVideoUrl : sourceVideoUrl,
    coverUrl: previewCoverUrl.isNotEmpty ? previewCoverUrl : sourceCoverUrl,
    shareVideoUrl: previewVideoUrl.isNotEmpty
        ? previewVideoUrl
        : sourceVideoUrl,
    shareCoverUrl: previewCoverUrl.isNotEmpty
        ? previewCoverUrl
        : sourceCoverUrl,
    withdrawMoneyTip: '',
    activeUserName: '',
    activeUserAvatar: '',
    activeUserCreateDays: 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "template_type": templateType,
    "prompt": prompt,
    "source_audio_url": sourceAudioUrl,
    "source_cover_url": sourceCoverUrl,
    "source_video_url": sourceVideoUrl,
    "preview_cover_url": previewCoverUrl,
    "preview_video_url": previewVideoUrl,
    "source_duration": sourceDuration,
    "mini_preview_video_url": miniPreviewVideoUrl,
  };
}

int _parseTemplateInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

String _parseTemplateString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String _legacyTemplateRightsType(AiVideoGenerationType type) {
  switch (type) {
    case AiVideoGenerationType.textToVideo:
      return 'ai_text2_video';
    case AiVideoGenerationType.imageToVideo:
    case AiVideoGenerationType.embraceVideo:
    case AiVideoGenerationType.firstAndEndFrame:
    case AiVideoGenerationType.multipleImages:
      return 'ai_image2_video';
  }
}

AiVideoGenerationType _legacyVideoType(String templateType) {
  return templateType == 'ai_text2_video'
      ? AiVideoGenerationType.textToVideo
      : AiVideoGenerationType.imageToVideo;
}

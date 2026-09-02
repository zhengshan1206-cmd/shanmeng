import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ai_video_square_model.dart';

part 'ai_video_generation_model.g.dart';

@JsonEnum(valueField: 'code')
enum AiVideoStatus {
  // 1 已创建
  taskCreated(1),
  // 2 已提交
  taskSubmitted(2),
  // 3 生成中
  generating(3),
  // 4 成功
  done(4),
  // 5 失败
  failed(5);

  // // 6 失败
  // deleted(6);

  final int code;

  const AiVideoStatus(this.code);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AiVideoGenerationTaskModel {
  int id;
  String? date;
  AiVideoStatus status;
  String? taskId;
  String? prompt;
  String? negativePrompt;
  String? image;
  String? imageTail;
  AiVideoGenerationType type;
  String? multiImage;
  String? bgmUrl;
  int duration;
  String aspectRatio;
  double cfgScale;
  String mode;
  int integral;
  int costIntegral;
  String? coverUrl;
  String? videoUrl;
  String? shareVideoUrl;
  String? shareCoverUrl;
  int taskSort;
  int dealStartTime;
  int dealEndTime;
  String platform;
  int? deleteTime;
  String createAt;
  String updateAt;

  AiVideoGenerationTaskModel({
    required this.id,
    this.date,
    required this.status,
    this.taskId,
    this.prompt,
    this.negativePrompt,
    this.image,
    this.imageTail,
    required this.type,
    required this.duration,
    required this.aspectRatio,
    required this.cfgScale,
    required this.mode,
    required this.integral,
    required this.costIntegral,
    this.multiImage,
    this.bgmUrl,
    this.coverUrl,
    this.videoUrl,
    this.shareVideoUrl,
    this.shareCoverUrl,
    required this.taskSort,
    required this.dealStartTime,
    required this.dealEndTime,
    required this.platform,
    this.deleteTime,
    required this.createAt,
    required this.updateAt,
  });

  AiVideoGenerationTaskModel copyWith({
    int? id,
    String? date,
    AiVideoStatus? status,
    String? taskId,
    String? prompt,
    String? negativePrompt,
    String? image,
    String? imageTail,
    AiVideoGenerationType? type,
    int? duration,
    String? aspectRatio,
    double? cfgScale,
    String? mode,
    String? multiImage,
    String? bgmUrl,
    int? integral,
    int? costIntegral,
    String? coverUrl,
    String? videoUrl,
    String? shareVideoUrl,
    String? shareCoverUrl,
    int? taskSort,
    int? dealStartTime,
    int? dealEndTime,
    String? platform,
    int? deleteTime,
    String? createAt,
    String? updateAt,
  }) {
    return AiVideoGenerationTaskModel(
      id: id ?? this.id,
      date: date ?? this.date,
      status: status ?? this.status,
      taskId: taskId ?? this.taskId,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      image: image ?? this.image,
      imageTail: imageTail ?? this.imageTail,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      cfgScale: cfgScale ?? this.cfgScale,
      mode: mode ?? this.mode,
      multiImage: multiImage ?? this.multiImage,
      bgmUrl: bgmUrl ?? this.bgmUrl,
      integral: integral ?? this.integral,
      costIntegral: costIntegral ?? this.costIntegral,
      coverUrl: coverUrl ?? this.coverUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      shareVideoUrl: shareVideoUrl ?? this.shareVideoUrl,
      shareCoverUrl: shareCoverUrl ?? this.shareCoverUrl,
      taskSort: taskSort ?? this.taskSort,
      dealStartTime: dealStartTime ?? this.dealStartTime,
      dealEndTime: dealEndTime ?? this.dealEndTime,
      platform: platform ?? this.platform,
      deleteTime: deleteTime ?? this.deleteTime,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  List<String>? get images => image?.split(',');

  List<String>? get multiImages => multiImage?.split('&&');

  bool get isDeleted => (deleteTime != null);

  factory AiVideoGenerationTaskModel.fromRawJson(String str) =>
      AiVideoGenerationTaskModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiVideoGenerationTaskModel.fromJson(Map<String, dynamic> json) =>
      _$AiVideoGenerationTaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$AiVideoGenerationTaskModelToJson(this);
}

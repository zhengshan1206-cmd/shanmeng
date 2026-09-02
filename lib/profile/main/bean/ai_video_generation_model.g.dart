// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_video_generation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiVideoGenerationTaskModel _$AiVideoGenerationTaskModelFromJson(
  Map<String, dynamic> json,
) => AiVideoGenerationTaskModel(
  id: (json['id'] as num).toInt(),
  date: json['date'] as String?,
  status: $enumDecode(_$AiVideoStatusEnumMap, json['status']),
  taskId: json['task_id'] as String?,
  prompt: json['prompt'] as String?,
  negativePrompt: json['negative_prompt'] as String?,
  image: json['image'] as String?,
  imageTail: json['image_tail'] as String?,
  multiImage: json['multi_image'] as String?,
  bgmUrl: json['bgm_url'] as String?,
  type: $enumDecode(_$AiVideoGenerationTypeEnumMap, json['type']),
  duration: (json['duration'] as num).toInt(),
  aspectRatio: json['aspect_ratio'] as String,
  cfgScale: (json['cfg_scale'] as num).toDouble(),
  mode: json['mode'] as String,
  integral: (json['integral'] as num).toInt(),
  costIntegral: (json['cost_integral'] as num).toInt(),
  coverUrl: json['cover_url'] as String?,
  videoUrl: json['video_url'] as String?,
  shareVideoUrl: json['share_video_url'] as String?,
  shareCoverUrl: json['share_cover_url'] as String?,
  taskSort: (json['task_sort'] as num).toInt(),
  dealStartTime: (json['deal_start_time'] as num).toInt(),
  dealEndTime: (json['deal_end_time'] as num).toInt(),
  platform: json['platform'] as String,
  deleteTime: (json['delete_time'] as num?)?.toInt(),
  createAt: json['create_at'] as String,
  updateAt: json['update_at'] as String,
);

Map<String, dynamic> _$AiVideoGenerationTaskModelToJson(
  AiVideoGenerationTaskModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date,
  'status': _$AiVideoStatusEnumMap[instance.status]!,
  'task_id': instance.taskId,
  'prompt': instance.prompt,
  'negative_prompt': instance.negativePrompt,
  'image': instance.image,
  'image_tail': instance.imageTail,
  'bgm_url': instance.bgmUrl,
  'type': _$AiVideoGenerationTypeEnumMap[instance.type]!,
  'duration': instance.duration,
  'aspect_ratio': instance.aspectRatio,
  'cfg_scale': instance.cfgScale,
  "multi_image": instance.multiImage,
  'mode': instance.mode,
  'integral': instance.integral,
  'cost_integral': instance.costIntegral,
  'cover_url': instance.coverUrl,
  'video_url': instance.videoUrl,
  'share_video_url': instance.shareVideoUrl,
  'share_cover_url': instance.shareCoverUrl,
  'task_sort': instance.taskSort,
  'deal_start_time': instance.dealStartTime,
  'deal_end_time': instance.dealEndTime,
  'platform': instance.platform,
  'delete_time': instance.deleteTime,
  'create_at': instance.createAt,
  'update_at': instance.updateAt,
};

const _$AiVideoStatusEnumMap = {
  AiVideoStatus.taskCreated: 1,
  AiVideoStatus.taskSubmitted: 2,
  AiVideoStatus.generating: 3,
  AiVideoStatus.done: 4,
  AiVideoStatus.failed: 5,
};

const _$AiVideoGenerationTypeEnumMap = {
  AiVideoGenerationType.textToVideo: 1,
  AiVideoGenerationType.imageToVideo: 2,
  AiVideoGenerationType.embraceVideo: 3,
  AiVideoGenerationType.firstAndEndFrame: 5,
  AiVideoGenerationType.multipleImages: 6,
};

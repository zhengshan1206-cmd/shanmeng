// To parse this JSON data, do
//
//     final videoWorksBean = videoWorksBeanFromJson(jsonString);

import 'dart:convert';

VideoWorksBean videoWorksBeanFromJson(String str) =>
    VideoWorksBean.fromJson(json.decode(str));

String videoWorksBeanToJson(VideoWorksBean data) => json.encode(data.toJson());

class VideoWorksBean {
  int id;
  String coverUrl;
  String videoUrl;
  String createAt;
  String duration;
  String videoSource;
  String status;
  // status字段  状态枚举依次为：created/queued/processing/success/fail ,

  VideoWorksBean({
    required this.id,
    required this.coverUrl,
    required this.videoUrl,
    required this.createAt,
    required this.duration,
    required this.videoSource,
    required this.status,
  });

  factory VideoWorksBean.fromJson(Map<String, dynamic> json) => VideoWorksBean(
    id: (json["id"] as num?)?.toInt() ?? 0,
    coverUrl: json["cover_url"]?.toString() ?? '',
    videoUrl: json["video_url"]?.toString() ?? '',
    createAt: json["create_at"]?.toString() ?? '',
    duration: json["duration"]?.toString() ?? '',
    videoSource: json["video_source"]?.toString() ?? 'ai_video',
    status: json["status"]?.toString() ?? 'created',
  );

  bool get isSuccess => status == 'success';
  bool get isFail => status == 'fail';
  bool get isProcessing =>
      status == 'created' || status == 'queued' || status == 'processing';

  Map<String, dynamic> toJson() => {
    "id": id,
    "cover_url": coverUrl,
    "video_url": videoUrl,
    "create_at": createAt,
    "duration": duration,
    "video_source": videoSource,
    "status": status,
  };
}

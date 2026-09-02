enum PayPreviewLayout { background, videoList }

class PayPreviewMedia {
  PayPreviewMedia({
    required this.coverUrl,
    this.videoUrl = '',
    this.aspectRatio = '4:3',
  });

  final String coverUrl;
  final String videoUrl;
  final String aspectRatio;

  bool get hasVideo {
    final String value = videoUrl.trim().toLowerCase();
    return value.isNotEmpty && value != 'null' && value != 'undefined';
  }

  double get aspectRatioValue {
    final String raw = aspectRatio.trim();
    if (!raw.contains(':')) return 4 / 3;
    final List<String> parts = raw.split(':');
    if (parts.length != 2) return 4 / 3;
    final double? width = double.tryParse(parts[0]);
    final double? height = double.tryParse(parts[1]);
    if (width == null || height == null || width <= 0 || height <= 0) {
      return 4 / 3;
    }
    return width / height;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'cover_url': coverUrl,
    'video_url': videoUrl,
    'aspect_ratio': aspectRatio,
  };

  factory PayPreviewMedia.fromJson(Map<String, dynamic> json) {
    return PayPreviewMedia(
      coverUrl: json['cover_url']?.toString() ?? '',
      videoUrl: json['video_url']?.toString() ?? '',
      aspectRatio: json['aspect_ratio']?.toString() ?? '4:3',
    );
  }
}

class PayPreviewPayload {
  PayPreviewPayload({required this.layout, required this.items});

  final PayPreviewLayout layout;
  final List<PayPreviewMedia> items;

  bool get hasItems => items.isNotEmpty;

  PayPreviewMedia? get firstItem => hasItems ? items.first : null;

  String get backgroundUrl => firstItem?.coverUrl ?? '';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'layout': layout.name,
    'items': items.map((PayPreviewMedia item) => item.toJson()).toList(),
  };

  factory PayPreviewPayload.fromJson(Map<String, dynamic> json) {
    final String rawLayout = json['layout']?.toString() ?? '';
    final dynamic rawItems = json['items'];
    final List<PayPreviewMedia> parsedItems = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (Map item) => PayPreviewMedia.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <PayPreviewMedia>[];
    return PayPreviewPayload(
      layout: rawLayout == PayPreviewLayout.videoList.name
          ? PayPreviewLayout.videoList
          : PayPreviewLayout.background,
      items: parsedItems,
    );
  }
}

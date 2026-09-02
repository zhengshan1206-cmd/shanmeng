

class ImageBean {
  int? id;
  int? status;
  String? title;
  String? key;
  String? iconUrl;
  String? bgUrl;

  ImageBean({
    this.id,
    this.status,
    this.title,
    this.key,
    this.iconUrl,
    this.bgUrl,
  });

  factory ImageBean.fromJson(Map<String, dynamic> json) {
    return ImageBean(
      id: json['id'],
      status: json['status'],
      title: json['title'],
      key: json['key'],
      iconUrl: json['icon_url'],
      bgUrl: json['bg_url'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'title': title,  
      'key': key,
      'icon_url': iconUrl,
      'bg_url': bgUrl,
    };
  }
}
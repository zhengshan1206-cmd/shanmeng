class HomeBannerBean {
  int id;
  int type;
  String? imgUrl;
  String? jumpParam;
  String? title;
  String? jumpUrl;
  String? description;

  HomeBannerBean({
    required this.id,
    required this.type,
    this.imgUrl,
    this.jumpParam,
    this.title,
    this.jumpUrl,
    this.description,
  });

  factory HomeBannerBean.fromJson(Map<String, dynamic> json) {
    return HomeBannerBean(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      jumpParam: json['jump_param'],
      imgUrl: json['img_url'],
      jumpUrl: json['jump_url'] ?? '',
      description: json['des'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {};
  }
}

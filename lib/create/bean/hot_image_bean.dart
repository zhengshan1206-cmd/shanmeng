
/*
 * @Author: duncy
 * @Date: 2026-04-13 13:50:13
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 19:12:41
 * @FilePath: /ling_bao/lib/create/bean/hot_image_bean.dart
 * @Description: 
 */


class HotImageBean1 {
  int? id;
  String? title;
  int? integral;
  String? url;
  String? thumbUrl;
  List<String>? prompts;
  String? prompt;

  HotImageBean1({
    this.id,
    this.title,
    this.integral,
    this.url,
    this.thumbUrl,
    this.prompts,
    this.prompt,
  });

  factory HotImageBean1.fromJson(Map<String, dynamic> json) {
    return HotImageBean1(
      id: json['id'],
      title: json['title'],
      integral: json['integral_user'],
      url: json['url'],
      prompts: json['prompts'] ?? [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'title': title,  
      'integral_user': integral,
      'url': url,
      'prompts': prompts,
    };
  }

  factory HotImageBean1.fromHomeJson(Map<String, dynamic> json) {
    return HotImageBean1(
      id: json['id'],
      title: json['title'],
      prompt: json['prompt'],
      thumbUrl: json['mini_pic_url'],
      url: json['pic_url'],
      prompts: json['prompts'] ?? [],
    );
  }
}
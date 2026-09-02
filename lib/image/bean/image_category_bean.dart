/*
 * @Author: duncy
 * @Date: 2026-04-13 18:30:17
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 18:33:21
 * @FilePath: /ling_bao/lib/image/bean/image_category_bean.dart
 * @Description: 
 */

class ImageCategoryBean {
  int? id;
  String? title;
  String? key;
  String? iconUrl;
  String? bgUrl;

  ImageCategoryBean({
    this.id,
    this.title,
    this.key,
    this.iconUrl,
    this.bgUrl,
  });

  factory ImageCategoryBean.fromJson(Map<String, dynamic> json) {
    return ImageCategoryBean(
      id: json['id'],
      title: json['title'],
      key: json['key'],
      iconUrl: json['icon_url']?.toString(),
      bgUrl: json['bg_url']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,  
      'key': key,
      'icon_url': iconUrl,
      'bg_url': bgUrl,
    };
  }
}
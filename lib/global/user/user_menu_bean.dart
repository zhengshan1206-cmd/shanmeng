/*
 * @Author: cold-x
 * @Date: 2025-09-17 15:18:04
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-12-10 10:48:45
 * @FilePath: /novel_oversea/lib/me/user/user_menu_bean.dart
 * @Description: 
 */
// To parse this JSON data, do
//
//     final userMenusBean = userMenusBeanFromJson(jsonString);

import 'dart:convert';

UserMenusBean userMenusBeanFromJson(String str) =>
    UserMenusBean.fromJson(json.decode(str));

String userMenusBeanToJson(UserMenusBean data) => json.encode(data.toJson());

class UserMenusBean {
  String title;
  bool show;
  String url;

  UserMenusBean({
    required this.title,
    required this.show,
    required this.url,
  });

  factory UserMenusBean.fromJson(Map<String, dynamic> json) => UserMenusBean(
        title: json["title"],
        show: json['loop_show_in_person_center'] ?? true,
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "url": url,
        "loop_show_in_person_center": show
      };
}

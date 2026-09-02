/*
 * @Author: cold-x
 * @Date: 2025-06-18 16:53:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-10 16:17:45
 * @FilePath: /ling_bao/lib/global/other/illegal_words/bean/illegal_words_bean.dart
 * @Description: 
 */


import 'dart:convert';

TextRiskBean textRiskBeanFromJson(String str) =>
    TextRiskBean.fromJson(json.decode(str));

String textRiskBeanToJson(TextRiskBean data) => json.encode(data.toJson());

class TextRiskBean {
  bool isRisk;
  List<String> labelName;
  String markContent;

  TextRiskBean({
    required this.isRisk,
    required this.labelName,
    required this.markContent,
  });

  factory TextRiskBean.fromJson(Map<String, dynamic> json) => TextRiskBean(
        isRisk: json["isRisk"] ?? false,
        labelName: List<String>.from((json["labelName"] ?? []).map((x) => x)),
        markContent: json["markContent"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "isRisk": isRisk,
        "labelName": List<dynamic>.from(labelName.map((x) => x)),
        "markContent": markContent,
      };
}


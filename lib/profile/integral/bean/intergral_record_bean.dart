/*
 * @Author: duncy
 * @Date: 2026-04-13 13:50:13
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 14:31:11
 * @FilePath: /ling_bao/lib/profile/integral/bean/intergral_record_bean.dart
 * @Description: 
 */


class IntergralRecordBean {
  String? itemDesc;
  int? intergral;
  String? createAt;
  int? userIntergral;

  IntergralRecordBean({
    this.itemDesc,
    this.intergral,
    this.createAt,
    this.userIntergral,
  });

  factory IntergralRecordBean.fromJson(Map<String, dynamic> json) {
    return IntergralRecordBean(
      itemDesc: json['des'],
      intergral: json['integral'],
      createAt: json['created_at'],
      userIntergral: json['user_integral'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'des': itemDesc,  
      'integral': intergral,
      'created_at': createAt,
      'user_integral': userIntergral,
    };
  }
}
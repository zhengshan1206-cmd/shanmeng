

import 'dart:convert';

class YeepayPayOrderBean {
  String id;
  String pay;
  Info info;
  String amount;
  int isSubscribeH5;

  YeepayPayOrderBean({
    required this.id,
    required this.pay,
    required this.info,
    required this.amount,
    required this.isSubscribeH5,
  });

  YeepayPayOrderBean copyWith({
    String? id,
    String? pay,
    Info? info,
    String? amount,
    int? isSubscribeH5,
  }) =>
      YeepayPayOrderBean(
        id: id ?? this.id,
        pay: pay ?? this.pay,
        info: info ?? this.info,
        amount: amount ?? this.amount,
        isSubscribeH5: isSubscribeH5 ?? this.isSubscribeH5,
      );

  factory YeepayPayOrderBean.fromRawJson(String str) =>
      YeepayPayOrderBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory YeepayPayOrderBean.fromJson(Map<String, dynamic> json) =>
      YeepayPayOrderBean(
        id: json["id"],
        pay: json["pay"],
        info: Info.fromJson(json["info"]),
        amount: json["amount"],
        isSubscribeH5: json["is_subscribe_h5"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pay": pay,
    "info": info.toJson(),
    "amount": amount,
    "is_subscribe_h5": isSubscribeH5,
  };
}

class Info {
  String prePayTn;
  String appId;
  String miniProgramPath;
  String miniProgramOrgId;

  Info({
    required this.prePayTn,
    required this.appId,
    required this.miniProgramPath,
    required this.miniProgramOrgId,
  });

  Info copyWith({
    String? prePayTn,
    String? appId,
    String? miniProgramPath,
    String? miniProgramOrgId,
  }) =>
      Info(
        prePayTn: prePayTn ?? this.prePayTn,
        appId: appId ?? this.appId,
        miniProgramPath: miniProgramPath ?? this.miniProgramPath,
        miniProgramOrgId: miniProgramOrgId ?? this.miniProgramOrgId,
      );

  factory Info.fromRawJson(String str) => Info.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    prePayTn: json["prePayTn"],
    appId: json["appId"],
    miniProgramPath: json["miniProgramPath"],
    miniProgramOrgId: json["miniProgramOrgId"],
  );

  Map<String, dynamic> toJson() => {
    "prePayTn": prePayTn,
    "appId": appId,
    "miniProgramPath": miniProgramPath,
    "miniProgramOrgId": miniProgramOrgId,
  };
}
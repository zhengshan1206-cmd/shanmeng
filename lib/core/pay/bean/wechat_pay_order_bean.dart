

import 'dart:convert';

WxPayOrderBean payOrderBeanFromJson(String str) =>
    WxPayOrderBean.fromJson(json.decode(str));

String payOrderBeanToJson(WxPayOrderBean data) => json.encode(data.toJson());

class WxPayOrderBean {
  String id;
  String pay;
  Info info;
  String amount;
  int isSubscribeH5;

  WxPayOrderBean({
    required this.id,
    required this.pay,
    required this.info,
    required this.amount,
    required this.isSubscribeH5,
  });

  factory WxPayOrderBean.fromJson(Map<String, dynamic> json) => WxPayOrderBean(
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
  String appid;
  String partnerid;
  String prepayid;
  String package;
  String noncestr;
  String timestamp;
  String sign;
  String packageValue;

  Info({
    required this.appid,
    required this.partnerid,
    required this.prepayid,
    required this.package,
    required this.noncestr,
    required this.timestamp,
    required this.sign,
    required this.packageValue,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    appid: json["appid"],
    partnerid: json["partnerid"],
    prepayid: json["prepayid"],
    package: json["package"],
    noncestr: json["noncestr"],
    timestamp: json["timestamp"],
    sign: json["sign"],
    packageValue: json["packageValue"],
  );

  Map<String, dynamic> toJson() => {
    "appid": appid,
    "partnerid": partnerid,
    "prepayid": prepayid,
    "package": package,
    "noncestr": noncestr,
    "timestamp": timestamp,
    "sign": sign,
    "packageValue": packageValue,
  };
}

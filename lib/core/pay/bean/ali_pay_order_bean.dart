
// To parse this JSON data, do
//
//     final aliPayOrderBean = aliPayOrderBeanFromJson(jsonString);

import 'dart:convert';

AliPayOrderBean aliPayOrderBeanFromJson(String str) =>
    AliPayOrderBean.fromJson(json.decode(str));

String aliPayOrderBeanToJson(AliPayOrderBean data) =>
    json.encode(data.toJson());

class AliPayOrderBean {
  String id;
  String pay;
  Info info;
  String amount;
  int isSubscribeH5;

  AliPayOrderBean({
    required this.id,
    required this.pay,
    required this.info,
    required this.amount,
    required this.isSubscribeH5,
  });

  factory AliPayOrderBean.fromJson(Map<String, dynamic> json) =>
      AliPayOrderBean(
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
  String orderInfo;
  bool isShowPayLoading;

  Info({
    required this.orderInfo,
    required this.isShowPayLoading,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    orderInfo: json["orderInfo"],
    isShowPayLoading: json["isShowPayLoading"],
  );

  Map<String, dynamic> toJson() => {
    "orderInfo": orderInfo,
    "isShowPayLoading": isShowPayLoading,
  };
}

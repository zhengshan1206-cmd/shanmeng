// To parse this JSON data, do
//
//     final integralPayListBean = integralPayListBeanFromJson(jsonString);

import 'dart:convert';

IntegralPayListBean integralPayListBeanFromJson(String str) =>
    IntegralPayListBean.fromJson(json.decode(str));

String integralPayListBeanToJson(IntegralPayListBean data) =>
    json.encode(data.toJson());

class IntegralPayListBean {
  String id;
  String appleVipId;
  String money;
  String mark;
  int isDefault;
  int isAgreement;
  String unitIntegralMoney;
  int integral;
  String crossedMoney;
  String des;
  String buttonTitle;
  Pays? pays;
  String title;
  String? localPrice;
  String? discountLocalPrice;
  String? localSymbol; ///当地价格符号

  IntegralPayListBean({
    required this.id,
    required this.appleVipId,
    required this.money,
    required this.mark,
    required this.isDefault,
    required this.isAgreement,
    required this.unitIntegralMoney,
    required this.integral,
    required this.crossedMoney,
    required this.des,
    required this.buttonTitle,
    required this.title,
    this.pays,
    this.localPrice,
    this.discountLocalPrice,
    this.localSymbol
  });

  factory IntegralPayListBean.fromJson(Map<String, dynamic> json) =>
      IntegralPayListBean(
        id: json["id"].toString(),
        appleVipId: json["apple_vip_id"],
        money: json["money"],
        mark: json["mark"],
        isDefault: json["is_default"],
        isAgreement: json["is_agreement"],
        unitIntegralMoney: json["unit_integral_money"],
        integral: json["integral"],
        crossedMoney: json["crossed_money"],
        des: json["desc"],
        buttonTitle: json["button_title"],
        pays: json["pays"] != null ? Pays.fromJson(json["pays"]) : null,
        title: json["title"],
        localPrice: json["local_price"],
        discountLocalPrice: json["discount_local_price"],
        localSymbol: json['local_symbol'] ?? ''
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "apple_vip_id": appleVipId,
        "money": money,
        "mark": mark,
        "is_default": isDefault,
        "is_agreement": isAgreement,
        "unit_integral_money": unitIntegralMoney,
        "integral": integral,
        "crossed_money": crossedMoney,
        "desc": des,
        "button_title": buttonTitle,
        "pays": pays?.toJson(),
        "title": title,
        'local_price': localPrice ?? '',
        'discount_local_price': discountLocalPrice ?? '',
        'local_symbol': localPrice ?? ''
      };
}

class Pays {
  int wxpay;
  int alipay;
  int yeepay;
  int applepay;

  Pays({
    required this.wxpay,
    required this.alipay,
    required this.yeepay,
    required this.applepay,
  });

  factory Pays.fromJson(Map<String, dynamic> json) => Pays(
        wxpay: json["wxpay"] ?? 0,
        alipay: json["alipay"] ?? 0,
        yeepay: json["yeepay"] ?? 0,
        applepay: json["applepay"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "wxpay": wxpay,
        "alipay": alipay,
        "yeepay": yeepay,
        "applepay": applepay,
      };
}

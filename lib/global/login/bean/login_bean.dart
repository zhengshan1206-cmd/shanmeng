// To parse this JSON data, do
//
//     final userInfoBean = userInfoBeanFromJson(jsonString);

import 'dart:convert';

LoginInfoBean userInfoBeanFromJson(String str) =>
    LoginInfoBean.fromJson(json.decode(str));

String userInfoBeanToJson(LoginInfoBean data) => json.encode(data.toJson());

class LoginInfoBean {
  int userId;
  int isVip;
  int vipLevel;
  String token;
  int? isFormal;
  String wsuri;
  dynamic wsuri2;
  int? appTaste;
  Config config;
  int? update;
  int forceUpdate;
  String version;
  String versionDes;
  String versionUrl;
  VerConfig verConfig;
  bool canBoundCode;

  LoginInfoBean({
    required this.userId,
    required this.isVip,
    required this.vipLevel,
    required this.token,
    required this.isFormal,
    required this.wsuri,
    required this.wsuri2,
    required this.appTaste,
    required this.config,
    required this.update,
    required this.forceUpdate,
    required this.version,
    required this.versionDes,
    required this.versionUrl,
    required this.verConfig,
    required this.canBoundCode,
  });

  factory LoginInfoBean.fromJson(Map<String, dynamic> json) => LoginInfoBean(
        userId: json["user_id"],
        isVip: json["is_vip"],
        vipLevel: json["vip_level"],
        token: json["token"],
        isFormal: json["is_formal"],
        wsuri: json["wsuri"] ?? "",
        wsuri2: json["wsuri2"] ?? "",
        appTaste: json["app_taste"],
        config: Config.fromJson(json["config"] ?? {}),
        update: json["update"],
        forceUpdate: json["force_update"] ?? 0,
        version: json["version"] ?? "",
        versionDes: json["version_des"] ?? "",
        versionUrl: json["version_url"] ?? "",
        verConfig: VerConfig.fromJson(json["ver_config"] ?? {}),
        canBoundCode: json["can_bound_code"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "is_vip": isVip,
        "vip_level": vipLevel,
        "token": token,
        "is_formal": isFormal,
        "wsuri": wsuri,
        "wsuri2": wsuri2,
        "app_taste": appTaste,
        "config": config.toJson(),
        "update": update,
        "force_update": forceUpdate,
        "version": version,
        "version_des": versionDes,
        "version_url": versionUrl,
        "ver_config": verConfig.toJson(),
        "can_bound_code": canBoundCode,
      };
}

class Config {
  String? privacy;
  String? protocol;
  String? userintegral;
  String? uservip;
  String? customerService;

  Config({
    required this.privacy,
    required this.protocol,
    required this.userintegral,
    required this.uservip,
    required this.customerService,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        privacy: json["privacy"] ?? '',
        protocol: json["protocol"] ?? '',
        userintegral: json["userintegral"] ?? '',
        uservip: json["uservip"] ?? '',
        customerService: json["customer_service"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "privacy": privacy,
        "protocol": protocol,
        "userintegral": userintegral,
        "uservip": uservip,
        "customer_service": customerService,
      };
}

class VerConfig {
  String landingPage;
  int allowTouristsVip;
  int launchPage;

  VerConfig({
    required this.landingPage,
    required this.allowTouristsVip,
    required this.launchPage,
  });

  factory VerConfig.fromJson(Map<String, dynamic> json) => VerConfig(
        landingPage: json["landing_page"] ?? "",
        allowTouristsVip: json["allow_tourists_vip"] ?? 0,
        launchPage: json["launch_page"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "landing_page": landingPage,
        "allow_tourists_vip": allowTouristsVip,
        "launch_page": launchPage,
      };
}

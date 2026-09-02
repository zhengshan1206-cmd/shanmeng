import 'dart:convert';

class LaunchInfoBean {
  int userId;
  int isVip;
  int vipLevel;
  String token;
  int isFormal;
  int? isAudit;
  String userCreatedAt;
  VerConfig? config;
  String? adjustAppID; /// adjust APP ID
  String? adjustFBAppID; /// adjustFBID
  int? hasGiveWords; /// 是否赠送过字数

  LaunchInfoBean({
    required this.userId,
    required this.isVip,
    required this.vipLevel,
    required this.token,
    required this.isFormal,
    required this.userCreatedAt,
    this.isAudit,
    this.config,
    this.adjustAppID,
    this.adjustFBAppID,
    this.hasGiveWords,
  });

  LaunchInfoBean copyWith({
    int? userId,
    int? isVip,
    int? vipLevel,
    String? token,
    int? isFormal,
    String? userCreatedAt,
    int? isAudit,
    String? adjustAppID,
    String? adjustFBAppID,
    int? hasGiveWords,
  }) =>
      LaunchInfoBean(
        userId: userId ?? this.userId,
        isVip: isVip ?? this.isVip,
        vipLevel: vipLevel ?? this.vipLevel,
        token: token ?? this.token,
        isFormal: isFormal ?? this.isFormal,
        userCreatedAt: userCreatedAt ?? this.userCreatedAt,
        isAudit: isAudit ?? this.isAudit,
        adjustAppID: adjustAppID ?? this.adjustAppID,
        adjustFBAppID: adjustFBAppID ?? this.adjustFBAppID,
        hasGiveWords: hasGiveWords ?? this.hasGiveWords
      );

  factory LaunchInfoBean.fromRawJson(String str) =>
      LaunchInfoBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LaunchInfoBean.fromJson(Map<String, dynamic> json) => LaunchInfoBean(
        userId: json["user_id"],
        isVip: json["is_vip"],
        vipLevel: json["vip_level"],
        token: json["token"],
        isFormal: json["is_formal"],
        userCreatedAt: json['user_created_at'] ?? "",
        isAudit: json["is_audit"] ?? 0,
        config: VerConfig.fromJson(json["ver_config"]),
        adjustAppID: json['adjust_app_token'] ?? "",
        adjustFBAppID: json['fb_app_id'] ?? "",
        hasGiveWords: json['is_show_gift_words_pop'] ?? 0
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "is_vip": isVip,
        "vip_level": vipLevel,
        "token": token,
        "is_formal": isFormal,
        "user_created_at":userCreatedAt,
        "is_audit": isAudit,
        "ver_config": config?.toJson(),
        'is_show_gift_words_pop': hasGiveWords,
      };
}

class Config {
  String privacy;
  String protocol;
  String userintegral;
  String uservip;
  String customerService;

  Config({
    required this.privacy,
    required this.protocol,
    required this.userintegral,
    required this.uservip,
    required this.customerService,
  });

  Config copyWith({
    String? privacy,
    String? protocol,
    String? userintegral,
    String? uservip,
    String? customerService,
  }) =>
      Config(
        privacy: privacy ?? this.privacy,
        protocol: protocol ?? this.protocol,
        userintegral: userintegral ?? this.userintegral,
        uservip: uservip ?? this.uservip,
        customerService: customerService ?? this.customerService,
      );

  factory Config.fromRawJson(String str) => Config.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        privacy: json["privacy"],
        protocol: json["protocol"],
        userintegral: json["userintegral"],
        uservip: json["uservip"],
        customerService: json["customer_service"],
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
  String halfScreenPage;
  List<HalfScreenRightsDesc> halfScreenRightsDesc;

  VerConfig({
    required this.landingPage,
    required this.allowTouristsVip,
    required this.launchPage,
    required this.halfScreenPage,
    required this.halfScreenRightsDesc,
  });

  VerConfig copyWith({
    String? landingPage,
    int? allowTouristsVip,
    int? launchPage,
    String? halfScreenPage,
    List<HalfScreenRightsDesc>? halfScreenRightsDesc,
  }) =>
      VerConfig(
        landingPage: landingPage ?? this.landingPage,
        allowTouristsVip: allowTouristsVip ?? this.allowTouristsVip,
        launchPage: launchPage ?? this.launchPage,
        halfScreenPage: halfScreenPage ?? this.halfScreenPage,
        halfScreenRightsDesc: halfScreenRightsDesc ?? this.halfScreenRightsDesc,
      );

  factory VerConfig.fromRawJson(String str) =>
      VerConfig.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerConfig.fromJson(Map<String, dynamic> json) => VerConfig(
        landingPage: json["landing_page"] ?? "",
        allowTouristsVip: json["allow_tourists_vip"] ?? 0,
        launchPage: json["launch_page"] ?? 0,
        halfScreenPage: json["half_screen_page"] ?? "",
        halfScreenRightsDesc: json["half_screen_rights_desc"] != null
            ? List<HalfScreenRightsDesc>.from(json["half_screen_rights_desc"]
                .map((x) => HalfScreenRightsDesc.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "landing_page": landingPage,
        "allow_tourists_vip": allowTouristsVip,
        "launch_page": launchPage,
        "half_screen_page": halfScreenPage,
        "half_screen_rights_desc": halfScreenRightsDesc,
      };
}

class HalfScreenRightsDesc {
  String title;
  String icon;

  HalfScreenRightsDesc({
    required this.title,
    required this.icon,
  });

  factory HalfScreenRightsDesc.fromJson(Map<String, dynamic> json) =>
      HalfScreenRightsDesc(
        title: json["title"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "icon": icon,
      };
}

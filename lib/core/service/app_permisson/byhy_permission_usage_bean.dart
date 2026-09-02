
import 'dart:convert';

///权限使用数据
class PermissionUsageBean {
  String permissionName;
  String usage;

  PermissionUsageBean({
    required this.permissionName,
    required this.usage,
  });

  PermissionUsageBean copyWith({
    String? permissionName,
    String? usage,
  }) =>
      PermissionUsageBean(
        permissionName: permissionName ?? this.permissionName,
        usage: usage ?? this.usage,
      );

  factory PermissionUsageBean.fromRawJson(String str) =>
      PermissionUsageBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PermissionUsageBean.fromJson(Map<String, dynamic> json) =>
      PermissionUsageBean(
        permissionName: json["permissionName"],
        usage: json["usage"],
      );

  Map<String, dynamic> toJson() => {
    "permissionName": permissionName,
    "usage": usage,
  };
}

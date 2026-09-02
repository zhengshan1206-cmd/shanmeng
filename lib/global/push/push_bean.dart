/*
 * @Author: duncy
 * @Date: 2026-01-19 17:44:09
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-09 11:48:11
 * @FilePath: /novel_oversea/lib/global/push/push_bean.dart
 * @Description: 
 */


//推送数据类型
enum PushType {
  /// 打开app
  open('open_app'),

  /// 2: 页面跳转
  page('open_page'),

  /// 3: 内部webview
  internalWebView('open_external'),

  /// 4: 外部webview
  externalWebView('open_internal');

  final String value;
  const PushType(this.value);
  
  static PushType fromRawValue(String rawValue) {
    switch (rawValue) {
      case 'open_page':
        return page;
      case 'open_internal':
        return internalWebView;
      case 'open_external':
        return externalWebView;
      default:
        return open;
    }
  }
}



class PushBean {
  String? type;
  String? url;

  PushBean({
    this.type,
    this.url,
  });

  factory PushBean.fromJson(Map<String, dynamic> json) {
    return PushBean(
      type: json['push_type'],
      url: json['url'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'push_type': type,
      'url': url,  
    };
  }
}
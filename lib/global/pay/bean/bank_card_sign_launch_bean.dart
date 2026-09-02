class BankCardSignLaunchBean {
  final String url;
  final String token;

  const BankCardSignLaunchBean({required this.url, required this.token});

  factory BankCardSignLaunchBean.fromJson(Map<String, dynamic> json) {
    return BankCardSignLaunchBean(
      url: _asString(json['url']),
      token: _asString(json['token']),
    );
  }

  bool get shouldPost => token.isNotEmpty;

  Map<String, String> get postFields {
    if (!shouldPost) {
      return const <String, String>{};
    }
    return <String, String>{'token': token};
  }
}

String _asString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

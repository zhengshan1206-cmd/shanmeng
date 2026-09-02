/// 后端接口路径常量表。
///
/// 统一放在这里，避免业务层散落硬编码字符串。
class ApiPaths {
  static const String launch = 'api/login/tourist';
  static const String oneClickLogin = 'api/login/oneclickv2';
  static const String sendCode = 'api/login/sendCode';
  static const String loginByPhone = 'api/login/phone';
  static const String userInfo = 'api/user/info';
  static const String logout = 'api/user/logout';
  static const String deleteAccount = 'api/user/accountCancellations';
  static const String deviceInfo = 'api/user/device';

  static const String vipPackages = 'api/vip/happys';
  static const String tokenPackages = 'api/IntegralVip/happys';
  static const String vipOrderCreate = 'api/vip/order';
  static const String tokenOrderCreate = 'api/IntegralVip/order';
  static const String vipOrderQuery = 'api/vip/query';
  static const String tokenOrderQuery = 'api/IntegralVip/query';

  static const String imageUploadInfo = 'api/image/imageUpladInfo';
  static const String contentRisk = 'api/risk/risk';
  static const String textRisk = 'api/risk/textRisk';
  static const String videoDefaultPrompts = 'api/VideoAi/getDefaultPrompt';
  static const String createAiVideoTask = 'api/VideoAi/createAiVideoTask';
  static const String queryAiVideoTask = 'api/VideoAi/queryAiVideoTask';
  static const String aiVideoTaskList = 'api/VideoAi/getAiVideoTaskList';
}

import 'package:ling_bao/core/network/apis.dart';

class NovelApis extends APIs {
  /*
    付费页
  */
  /// 获取VIP套餐列表
  static const String vip = "api/vip/happys";

  /// 积分套餐列表
  static const String token = "api/IntegralVip/happys";

  /// 创建vip订单
  static const String orderCreate = "api/vip/orderv2";

  /// 创建积分订单
  static const String tokenCreate = "api/IntegralVip/orderv2";

  /// 查询vip订单
  static const String orderQuery = "api/vip/query";

  /// 查询积分订单
  static const String tokenQuery = "api/IntegralVip/query";

  /// vip订单补单
  static const String orderRepair = "novel/order/repair";

  /// iOS恢复购买
  static const String iOSRestorePurchase = "novel/order/iosRestorePurchase";

  ///公用
  /// 启动接口（游客登陆）- 获取 token
  static const String launch = 'api/login/tourist';

  ///违禁词检测
  static const String checkNovel = 'novel/aiNovel/checkAiNovel';

  ///违禁词检测列表
  static const String novelIllegalWordsList = 'novel/aiNovel/getCheckList';

  /*
    个人中心
  */

  ///协议列表
  static const String novelAppMenus = 'api/user/novelAppMenus';

  ///赠送字数
  static const String giftWordPack = 'novel/novel/giftWordPack';

  ///记录统计
  static const String getNovelCreateCount = 'novel/novel/getNovelCreateCount';

  ///获取公共配置
  static const String getCommonConfig = 'novel/config/getCommonConfig';

  ///升级更新
  static const String appUpgrade = 'api/upgrade/index';

  ///获取积分消耗列表
  static const String getIntegralConsumeList = 'api/IntegralVip/logs';

  ///获取是否可以试用
  static const String isAllowTryout = "novel/aiNovel/isAllowTryout";

  /*
    支付相关
  */

  ///vip运营配置
  static const String vipOperationPage = "api/PayPage/getPayPageMaterial";
}

/*
 * @Author: cold-x
 * @Date: 2025-06-09 19:51:33
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-13 16:20:03
 * @FilePath: /ling_bao/lib/global/const/const_string.dart
 * @Description: 
 */
class ConstString {
  static const kSystemAndroid = "android";
  static const kSystemIOS = "ios";

  ///苹果appstoreID
  static const kAppStoreID = "6747186147";

  /// 启动时，用户协议是否已同意
  static const kPrivacyChecked = "kPrivacyChecked";
  static const kSPPrivacyChecked = "kSPPrivacyChecked";

  /// 启动时，用户是否已经过引导页
  static const kLaunchGuideCheck = 'kLaunchGuideCheck';
  static const kUserEnteredGuide = 'kUserEnteredGuide';

  /// 付费页关闭时的二次关闭弹窗确认
  static const kCancelPaySecondTime = 'kCancelPaySecondTime';
  static const kCancelPaySecondTimeDuration = 10 * 60 * 1000;

  /// 是否进入过首页
  static const kUserEnteredHomePage = 'kUserEnteredHomePage';

  /// 未完成小说每日弹窗提示
  static const kDailyUncompleteNovel = 'kDailyUncompleteNovel';

  /// appstore评分弹窗提示
  static const kAppStoreReviewCheck = 'kAppStoreReviewCheck';

  /// appstore评分弹窗提示
  static const kLanguageSetting = 'kLanguageSetting';

  ///版本更新弹窗
  static const kAppVersionDialog = 'kAppVersionDialog';

  ///邮箱登录输入的验证邮箱
  static const kLoginEmailVerification = 'kLoginEmailVerification';

  ///用户是否进入过vip页面
  static const kEnteredVipPage = 'kEnteredVipPage';

  ///今日首页是否有弹推荐列表
  static const kHomeRecommendDialog = 'kHomeRecommendDialog';

  ///今日首页是否有评分弹窗
  static const kScoreHomeDialog = 'kScoreHomeDialog';

  ///用户是否进行过3星以上的评分
  static const kUserScoreInStore = 'kUserScoreInStore';

  /// firebase推送token
  static const kFirebasePushToken = 'kFirebasePushToken';

  ///大数据量存储
  ///vip数据
  static const kVipData = 'kVipData';

  ///积分数据
  static const kIntegralData = 'kIntegralData';

  ///用户数据
  static const kUserData = 'kUserData';

  ///启动数据
  static const kStartConfig = 'kStartConfig';
}

/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:34:40
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 17:15:16
 * @FilePath: /ling_bao/lib/global/routes/app_routes.dart
 * @Description: 
 */
part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  /*
    全局路由定义
  */

  ///启动页
  static const launch = '/launch';

  ///启动失败页
  static const launchFail = '/launch_fail';

  ///主页
  static const main = '/main';

  ///首页
  static const home = '/home';

  ///广场
  static const square = '/square';

  ///我的
  static const profile = '/profile';

  ///登录
  static const login = '/login';
  static const loginPhone = '/login_phone';

  /// 创建
  static const create = '/create';

  /*
    首页广场页路由定义
  */
  ///广场专区
  static const squareZone = '/square_zone';

  ///广场列表详情
  static const tutorialDetail = '/strategy_details_page';

  /*
    AI视频
  */

  /// 视频详情页
  static const videoDetail = '/video_detail';

  /// 视频创作页
  static const caseCreate = '/case_create';

  /*
    个人中心
  */

  ///个人中心页
  static const userProfile = '/user_profile';

  ///引导页
  static const guide = '/guide';

  /// 创作记录详情
  static const recordDetail = '/record_detail';

  ///违禁词页
  static const illegalWords = '/illegal_words';

  ///设置
  static const setting = '/setting';

  ///消息
  static const message = '/message';

  ///消息详情
  static const messageDetails = '/message_details';

  ///订单管理
  static const orderManagement = '/order_management';

  ///历史订单
  static const orderHistory = '/order_history';

  ///关于我们
  static const aboutUs = '/aboutUs';

  ///用户反馈
  static const feedback = '/feedback';

  ///新版付费页
  static const payCenterPage = '/pay_center_page';

  ///选择银行卡页
  static const bankCardSelectPage = '/bank_card_select_page';

  ///支付成功
  static const memberPaySuccess = '/member_pay_success';

  ///积分商品消耗列表页
  static const creditsItemList = '/credits_item_list';

  ///新用户支付页
  static const newUserPayPage = '/new_user_pay_page';

  ///签到页
  static const checkinPage = '/checkin';

  ///调查问卷
  static const surveyPage = '/survey';
}

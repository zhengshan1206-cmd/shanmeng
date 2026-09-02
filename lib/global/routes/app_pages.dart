import 'package:get/get.dart';
import 'package:ling_bao/create/binding/create_binding.dart';
import 'package:ling_bao/create/create_page.dart';
import 'package:ling_bao/global/launch/page/guide_step_page.dart';
import 'package:ling_bao/global/launch/page/launch_page.dart';
import 'package:ling_bao/global/login/binbing/login_binding.dart';
import 'package:ling_bao/global/login/controller/login_controller.dart';
import 'package:ling_bao/global/login/page/login_page.dart';
import 'package:ling_bao/global/login/page/login_phone_page.dart';
import 'package:ling_bao/global/pay/binding/bank_card_select_binding.dart';
import 'package:ling_bao/global/pay/binding/pay_binding.dart';
import 'package:ling_bao/global/pay/page/bank_card_select_page.dart';
import 'package:ling_bao/global/pay/page/pay_center_page.dart';
import 'package:ling_bao/profile/integral/binding/intergral_record_binding.dart';
import 'package:ling_bao/profile/integral/page/intergral_record_page.dart';
import 'package:ling_bao/profile/message/binding/message_binding.dart';
import 'package:ling_bao/profile/message/page/message_details_page.dart';
import 'package:ling_bao/profile/message/page/profile_message_page.dart';
import 'package:ling_bao/profile/order/page/profile_order_history_page.dart';
import 'package:ling_bao/profile/main/page/profile_page.dart';
import 'package:ling_bao/profile/order/page/profile_order_management_page.dart';
import 'package:ling_bao/profile/order/binding/order_history_binding.dart';
import 'package:ling_bao/profile/order/binding/order_management_binding.dart';
import 'package:ling_bao/profile/record/binding/record_detail_binding.dart';
import 'package:ling_bao/profile/record/page/record_detail_page.dart';
import 'package:ling_bao/video/main/binding/video_create_binding.dart';
import 'package:ling_bao/video/main/binding/video_detail_binding.dart';
import '../../profile/main/binding/profile_binding.dart';
import '../../video/main/page/home_video_detail_page.dart';
import '../main/main_page.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    /*
    全局路由
    */

    ///启动页
    GetPage(name: Routes.launch, page: () => const LaunchPage()),

    // ///启动失败页
    // GetPage(
    //   name: Routes.launchFail,
    //   page: () => const LaunchErrorPage(),
    // ),

    // /首页
    GetPage(
      name: Routes.main,
      page: () => MainPage(),
      transition: Transition.noTransition,
    ),

    // ///我的独立路由
    // GetPage(
    //     name: Routes.profile,
    //     page: () => ProfilePage(),
    //     binding: ProfileBinding(),
    //     transition: Transition.noTransition),

    ///登录页
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
      transition: Transition.downToUp,
    ),

    ///登录手机页
    GetPage(
      name: Routes.loginPhone,
      page: () => LoginPhonePage(type: LoginType.phone),
      binding: LoginBinding(),
    ),

    ///引导页
    GetPage(
      name: Routes.guide,
      page: () => GuideStepPage(),
      // binding: GuideBinding(),
    ),

    ///个人中心页
    GetPage(
      name: Routes.userProfile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),

    /// 记录详情页
    GetPage(
      name: Routes.recordDetail,
      page: () => RecordDetailPage(),
      binding: RecordDetailBinding(),
    ),

    ///设置
    // GetPage(
    //   name: Routes.setting,
    //   page: () => SetupPage(),
    //   binding: SetupBinding(),
    // ),

    /// 消息通知
    GetPage(
      name: Routes.message,
      page: () => ProfileMessagePage(),
      binding: MessageBinding(),
    ),

    /// 消息详情
    GetPage(name: Routes.messageDetails, page: () => MessageDetailsPage()),

    /// 订单管理
    GetPage(
      name: Routes.orderManagement,
      page: () => ProfileOrderManagementPage(),
      binding: OrderManagementBinding(),
    ),

    /// 历史订单
    GetPage(
      name: Routes.orderHistory,
      page: () => ProfileOrderHistoryPage(),
      binding: OrderHistoryBinding(),
    ),

    // ///用户反馈
    // GetPage(name: Routes.feedback, page: () => FeedbackPage()),

    // ///关于我们
    // GetPage(
    //   name: Routes.aboutUs,
    //   page: () => AboutUsPage(),
    //   binding: AboutUsBinding(),
    // ),

    ///创建页
    GetPage(
      name: Routes.create,
      page: () => CreatePage(),
      binding: CreateBinding(),
    ),

    ///付费页
    GetPage(
      name: Routes.payCenterPage,
      page: () => PayCenterPage(),
      binding: PayBinding(),
      transition: Transition.downToUp,
    ),

    /// 选择银行卡
    GetPage(
      name: Routes.bankCardSelectPage,
      page: () => const BankCardSelectPage(),
      binding: BankCardSelectBinding(),
    ),

    // ///支付成功
    // GetPage(
    //   name: Routes.memberPaySuccess,
    //   page: () => MemberPaySuccessPage(),
    //   binding: MemberPaySuccessBinding(),
    // ),

    ///积分消耗列表页
    GetPage(
      name: Routes.creditsItemList,
      page: () => IntergralRecordPage(),
      binding: IntergralRecordBinding(),
    ),

    // ///新用户支付页
    // GetPage(
    //   name: Routes.newUserPayPage,
    //   page: () => NewUserPayPage(),
    //   transition: Transition.downToUp,
    // ),

    // ///签到页
    // GetPage(
    //   name: Routes.checkinPage,
    //   page: () => CheckinPage(),
    //   binding: CheckinBinding(),
    // ),

    // ///调查问卷
    // GetPage(name: Routes.surveyPage, page: () => SurveyPage()),

    /// AI视频详情页
    GetPage(
      name: Routes.videoDetail,
      page: () => VideoMorePage(),
      binding: VideoDetailBinding(),
    ),

    /// AI视频详情页
    GetPage(
      name: Routes.caseCreate,
      page: () => VideoCreatePage(),
      binding: VideoCreateBinding(),
    ),
  ];
}

class RouterUtil {
  static String initialRoute() => nextRoute();

  static String nextRoute() {
    return Routes.launch;
  }
}

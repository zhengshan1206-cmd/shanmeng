/*
 * @Author: duncy
 * @Date: 2025-10-13 14:37:06
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-26 16:23:47
 * @FilePath: /ling_bao/lib/global/pay/controller/pay_controller.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:ling_bao/core/pay/pay_manager.dart';
import 'package:ling_bao/global/launch/controller/launch_controller.dart';
import 'package:ling_bao/global/pay/bean/integral_pay_list_bean.dart';
import 'package:ling_bao/global/pay/bean/pay_preview_media.dart';
import 'package:ling_bao/global/pay/bean/vip_type_bean.dart';
import 'package:ling_bao/global/pay/controller/pay_style_manager.dart';
import 'package:ling_bao/global/routes/app_pages.dart';

import '../../user/user.dart';
import '../view/member_agree_dialog.dart';
import '../view/pay_retain_dialog.dart';

///付费类型
enum PayType {
  ///vip付费
  vip,

  ///增加token付费
  token,
}

class PayController extends GetxController {
  PayManager payManager = PayManager();
  late final Worker _vipListWorker;
  late final Worker _vipSelectWorker;
  late final Worker _bankSignReturnWorker;

  ///付费页类型
  Rx<PayType> payType = PayType.vip.obs;

  ///是否是流程引导页
  bool isGuide = false;

  ///付费页样式管理器
  late PayStyleManager styleManager;

  ///是否需要回到主页
  bool returnHome = false;

  ///试用开关
  bool trialSwitch = true;

  ///来源位置
  int sourcePosition = 4;

  ///协议是否阅读
  RxBool agreementChecked = false.obs;

  /// 是否勾选新人立减特权按钮
  RxBool newUserDiscount = true.obs;

  /// 默认背景url
  String bgUrl = '';

  PayPreviewPayload? previewPayload;

  final UserController user = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    payType.value = user.isVip ? PayType.token : PayType.vip;
    final args = Get.arguments as Map<String, dynamic>?;
    isGuide = args?['guide'] ?? false;
    returnHome = args?['isBackHome'] ?? false;
    sourcePosition = args?['sourcePosition'] ?? 4;
    bgUrl = args?['url'] ?? '';
    final dynamic rawPreviewPayload = args?['preview_payload'];
    if (rawPreviewPayload is Map) {
      previewPayload = PayPreviewPayload.fromJson(
        Map<String, dynamic>.from(rawPreviewPayload),
      );
      if (bgUrl.isEmpty && previewPayload!.backgroundUrl.isNotEmpty) {
        bgUrl = previewPayload!.backgroundUrl;
      }
    }

    payManager.payData.hasEnteredVip = true;

    ///付费页数据未加载时
    if (payManager.payData.vipList.isEmpty ||
        payManager.payData.vipInterceptList.isEmpty) {
      if (!isGuide) {
        payManager.payData.init();
      }
    }

    getPayPageStyle();
    payManager.initManager(
      payType.value == PayType.vip ? 0 : 1,
      success: () {
        if (isGuide || returnHome) {
          Get.offNamed(Routes.main);
        } else {
          Get.back();
        }
      },
    );
    _vipListWorker = ever<List<VipTypeBean>>(payManager.payData.vipList, (_) {
      if (payType.value == PayType.vip) {
        payManager.refreshVipPayMethods(
          vipList: getCurrentDataList() as List<VipTypeBean>,
        );
      }
    });
    _vipSelectWorker = ever<int>(payManager.selectIndex, (_) {
      if (payType.value == PayType.vip) {
        payManager.refreshVipPayMethods(
          vipList: getCurrentDataList() as List<VipTypeBean>,
        );
      }
    });
    _bankSignReturnWorker = ever<int>(user.bankSignReturnTick, (_) {
      if (payType.value == PayType.vip) {
        payManager.queryOrder();
      }
    });

    ///是否在审核
    agreementChecked.value = !Get.find<UserController>().isAudit();
  }

  ///获取付费页样式
  void getPayPageStyle() {
    String landingPage =
        Get.find<LaunchController>().launchInfo?.config?.landingPage ?? "";
    if (!landingPage.contains('pay_center_page__')) {
      landingPage = "pay_center_page__0__1";
    }
    int screenType = 1;
    int style = 1;
    try {
      screenType = int.parse(landingPage.split('__')[1]);

      ///检查横竖屏是否配置错误
      if (![0, 1].contains(screenType)) {
        screenType = 1;
      }

      ///检查样式是否配置错误
      style = int.parse(landingPage.split('__')[2]);
      if (![1, 2].contains(style)) {
        style = 1;
      }
    } catch (e) {
      // throw(e);
    }

    ///字数包默认样式
    if (payType.value == PayType.token) {
      screenType = 1;
      style = 1;
    }
    styleManager = PayStyleManager(
      type: screenType,
      style: style, // 1: 默认样式, 2: 黑色样式,
    );
  }

  /// 协议是否阅读
  void agreementCheckedChanged(bool value) {
    if (Get.find<UserController>().isAudit()) {
      agreementChecked.value = value;
    }
  }

  ///获取80%折扣比例的原价
  double getPriceForDiscount(VipTypeBean bean) {
    try {
      // double money = double.parse(bean.money);
      double money = double.parse(
        getPrice(bean).replaceAll(styleManager.getLocalSymbol(bean), ''),
      );

      return (money * 5 * 100).floor() / 100;
    } catch (e) {
      return double.parse(bean.money) * 5;
    }
  }

  ///获取当前套餐折扣比例
  int getPackageDiscount(VipTypeBean bean) {
    try {
      // double money = double.parse(bean.money);
      double money = double.parse(
        getPrice(
          bean,
          isDiscount: true,
        ).replaceAll(styleManager.getLocalSymbol(bean), ''),
      );
      // double crossMoney = double.parse(bean.crossedMoney ?? '0');
      double crossMoney = double.parse(
        getPrice(bean).replaceAll(styleManager.getLocalSymbol(bean), ''),
      );
      if (crossMoney > money) {
        return ((1 - money / crossMoney) * 100).floor();
      }
    } catch (e) {
      return 0;
    }
    return 0;
  }

  /// 是否显示新人立减特权
  bool showNewUserDiscountView() {
    if (payType.value == .vip &&
        newUserDiscount.value &&
        payManager.payData.vipList.length > 1 &&
        payManager.payData.vipDiscountList.isNotEmpty) {
      return true;
    }
    return false;
  }

  ///获取当前套餐数据
  List<dynamic> getCurrentDataList() {
    if (payType.value == .vip) {
      List<VipTypeBean> dataList = payManager.payData.vipList
          .cast<VipTypeBean>()
          .toList();

      /// 替换套餐
      if (payManager.payData.vipDiscountList.isNotEmpty &&
          !newUserDiscount.value &&
          dataList.length > 1) {
        dataList.replaceRange(1, 2, payManager.payData.vipDiscountList);
      }
      return dataList;
    } else {
      return payManager.payData.wordsPackageList
          .cast<IntegralPayListBean>()
          .toList();
    }
  }

  ///套餐切换
  void switchVipListCurrent(int index) {
    payManager.selectIndex.value = index;
  }

  /// 获取套餐按钮文案
  String getPackageButtonText({VipTypeBean? bean}) {
    String buttonTitle = "Purchase";
    if (bean != null) {
      return bean.buttonTitle ?? buttonTitle;
    }
    buttonTitle =
        getCurrentDataList()[payManager.selectIndex.value].buttonTitle;
    return buttonTitle;
  }

  ///开始支付
  void startPay({
    VipTypeBean? bean,
    String? payMethodKey,
    List<VipTypeBean>? vipList,
  }) async {
    if (!agreementChecked.value) {
      await Get.dialog(
        MemberAgreeDialog(
          onConfirm: () {
            payManager.startPay(
              bean: bean,
              payMethodKey: payMethodKey,
              vipList: vipList,
            );
          },
        ),
      );
    } else {
      payManager.startPay(
        bean: bean,
        payMethodKey: payMethodKey,
        vipList: vipList,
      );
    }
  }

  ///获取价格
  String getPrice(dynamic package, {bool isDiscount = false}) {
    return styleManager.getPrice(package, isDiscount: isDiscount);
  }

  ///关闭支付页,检查是否需要二次弹窗
  void closePayPage() async {
    if (payType.value == PayType.token || payManager.payData.vipList.isEmpty) {
      closeAndBack();
      return;
    }

    /// 引导流程付费页
    if (isGuide && payManager.payData.obList.isEmpty) {
      Get.offAllNamed(Routes.main);
      return;
    }
    int showRetain = 0;
    if (isGuide && payManager.payData.obList.isNotEmpty) {
      showRetain = 1;
    }
    if (!isGuide && payManager.payData.vipInterceptList.isNotEmpty) {
      showRetain = 2;
    }
    if (showRetain > 0) {
      await Get.bottomSheet(
        PayRetainDialog(type: showRetain),
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
      );
      closeAndBack();
    } else {
      closeAndBack();
    }
  }

  ///关闭返回
  void closeAndBack() {
    if (returnHome) {
      Get.offAllNamed(Routes.main);
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    _vipListWorker.dispose();
    _vipSelectWorker.dispose();
    _bankSignReturnWorker.dispose();
    payManager.dispose();
    super.onClose();
  }
}

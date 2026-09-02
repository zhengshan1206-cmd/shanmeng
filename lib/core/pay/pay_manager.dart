/*
 * @Author: duncy
 * @Date: 2025-09-23 09:45:36
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-06-03 13:54:19
 * @FilePath: /ling_bao/lib/core/pay/pay_manager.dart
 * @Description: 
 */

import 'dart:async';
import 'dart:io';
import 'package:alipay_kit/alipay_kit.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_nav_router_utils.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:wechat_kit/wechat_kit.dart';

import '../../global/login/controller/login_manager.dart';
import '../../global/launch/controller/launch_controller.dart';
import '../../global/launch/controller/launch_manager.dart';
import '../../global/main/main_controller.dart';
import '../../global/other/event_tracking/event_tracking.dart';
import '../../global/pay/bean/vip_type_bean.dart';
import '../../global/pay/page/bank_card_sign_web_view_page.dart';
import '../../profile/integral/controller/intergral_record_controller.dart';
import '../../global/routes/app_pages.dart';
import '../../global/user/user.dart';
import '../network/http_utils.dart';
import '../network/novel_apis.dart';
import '../ui/dialog/diolog_view.dart';
import '../ui/dialog/loading_dialog.dart';
import '../ui/dialog/toast.dart';
import '../ui/view/by_common_utils.dart';
import 'bean/ali_pay_order_bean.dart';
import 'bean/wechat_pay_order_bean.dart';
import 'bean/yeepay_order_bean.dart';
// import 'pay_engine.dart';
import 'pay_util.dart';

class SinglePayManager {
  ///套餐数据
  VipTypeBean bean;

  PayManager payManager;

  ///是否需要回到主页
  bool? returnHome;

  /// 支付页位置
  int sourcePosition;

  SinglePayManager(
    this.bean,
    this.payManager, {
    this.returnHome = true,
    required this.sourcePosition,
  });

  void init() {
    // payManager.payEngine.sourceType = sourcePosition;
    payManager.initManager(
      0,
      success: () {
        if (returnHome!) {
          Get.offNamed(Routes.main);
        } else {
          Get.back();
        }
      },
    );
  }

  ///开始支付
  void startPay() {
    payManager.startPay(bean: bean);
  }

  ///获取本地符号
  String getLocalSymbol() {
    return bean.localSymbol!.isNotEmpty ? bean.localSymbol! : '\$';
  }

  ///获取价格
  String getPrice({bool isDiscount = false}) {
    try {
      String price = isDiscount ? bean.discountLocalPrice! : bean.localPrice!;
      return price.isNotEmpty ? price : '\$${bean.money}';
    } catch (e) {
      return '\$${bean.money}';
    }
  }

  ///获取均价, 0表示每日均价， 1表示每月
  String getAveragePrice({bool isDiscount = false, int type = 0}) {
    String localprice = getPrice(isDiscount: isDiscount);
    int average = bean.day!;
    if (type == 1 && bean.vipLevel! > 30) {
      average = (bean.day! / 365 * 12).ceil();
    }
    try {
      double price = double.parse(localprice.replaceAll(bean.localSymbol!, ''));
      return '${(price / average * 100).round() / 100}';
    } catch (e) {
      return '${(double.parse(localprice.replaceAll(getLocalSymbol(), '')) / average * 100).round() / 100}';
    }
  }

  ///获取均价, 0表示每日均价， 1表示每月
  String getAverageText() {
    if (bean.vipLevel! > 30) {
      return '/mo';
    }
    return '/day';
  }

  /// 获取套餐按钮文案
  String getButtonText() {
    String buttonTitle = "Purchase";
    return bean.buttonTitle ?? buttonTitle;
  }

  void dispose() {
    payManager.dispose();
  }
}

class PayManager {
  // PayEngine payEngine = PayEngine();

  ///创建订单的配置ID
  String createOrderID = '';

  ///支付订单ID
  String orderID = '';

  /// 当前订单拉起方式
  String currentOrderCallMethod = '';

  ///苹果支付成功后查询订单状态的监听
  // late StreamSubscription paySuccessSubscription;

  ///付费页数据
  PayData payData = Get.find<PayData>();

  ///选中的会员套餐
  RxInt selectIndex = 0.obs;

  ///类型
  int payType = 0; //0 会员 1 积分
  ///是否正在查询支付订单
  bool isQuerying = false;

  Function()? completePay;

  /// 当前选中的支付方式
  String currentPayMethod = Platform.isAndroid ? "wxpay" : "apple";

  /// 可用的vip支付方式列表
  List<Map<String, dynamic>> payMethodBeans = [];

  /// 可用的字数包支付方式列表
  List<Map<String, dynamic>> wordPackagePayMethodBeans = [];

  /// 当前选中的vip支付方式索引
  RxInt currentPayMethodIndex = 0.obs;
  RxInt currentWordPackagePayMethodIndex = 0.obs;

  ///初始化
  void initManager(int type, {Function()? success}) {
    payType = type;
    // payEngine.initializeInAppPurchase(isComsume: payType == 1);
    completePay = success;

    ///监听支付结果
    payResult();
    subscribePayResult();
    _processPayMethods();
  }

  /// 取消订阅支付结果
  void cancelSubscribePayResult() {
    PaymentUtil().cancelSubscribeWXPayResp();
    PaymentUtil().cancelSubscribeAliPayResp();
  }

  /// 处理支付方式
  void _processPayMethods() {
    if (payType == 0) {
      try {
        final VipTypeBean? bean = _currentVipPackage();
        currentPayMethod = bean!.payTypes.isNotEmpty
            ? bean.payTypes.split(',').first
            : Platform.isAndroid
            ? "wxpay"
            : "apple";
      } catch (e) {
        // throw(e);
      }
      refreshVipPayMethods();
      return;
    }
    wordPackagePayMethodBeans = _buildPayMethodList(
      payData.wordPackagePayConfig,
    );
    if (wordPackagePayMethodBeans.isEmpty) {
      currentWordPackagePayMethodIndex.value = 0;
      currentPayMethod = '';
      return;
    }
    currentWordPackagePayMethodIndex.value = 0;
    currentPayMethod = wordPackagePayMethodBeans.first["payNameKey"];
  }

  Map<String, dynamic> _resolveVipPayConfig({
    VipTypeBean? bean,
    List<VipTypeBean>? vipList,
  }) {
    final VipTypeBean? targetBean =
        bean ?? _currentVipPackage(vipList: vipList);
    if (targetBean != null && targetBean.pays.hasPayload) {
      return targetBean.pays.toPayConfig();
    }
    return payData.payConfig;
  }

  VipTypeBean? _currentVipPackage({List<VipTypeBean>? vipList}) {
    final List<VipTypeBean> list = vipList ?? payData.vipList;
    if (list.isEmpty) {
      return null;
    }
    final int targetIndex = selectIndex.value;
    if (targetIndex < 0 || targetIndex >= list.length) {
      return list.first;
    }
    return list[targetIndex];
  }

  bool _isPayEnabled(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value == 1;
    }
    return value?.toString() == '1';
  }

  bool _isBankPayMethodKey(String? key) {
    return key == 'bank_subscribe';
  }

  bool _isSamePayMethodKey(String? left, String? right) {
    if (left == right) {
      return true;
    }
    return _isBankPayMethodKey(left) && _isBankPayMethodKey(right);
  }

  List<Map<String, dynamic>> _buildPayMethodList(
    Map<String, dynamic> payConfig, {
    String? payOrderKey,
  }) {
    List<String> payOrder = [];
    const List<String> defaultPayOder = [
      'wxpay',
      'alipay',
      'yeepay',
      'bank_subscribe',
      'zhongan_nopass',
    ];
    if (payOrderKey != null && payOrderKey.isNotEmpty) {
      payOrder = payOrderKey
          .split(',')
          .toSet()
          .union(defaultPayOder.toSet())
          .toList();
    } else {
      payOrder = defaultPayOder;
    }
    final List<Map<String, dynamic>> targetList = <Map<String, dynamic>>[];
    for (final String payType in payOrder) {
      if (_isPayEnabled(payConfig[payType])) {
        _addPayMethod(targetList, payType);
      }
    }
    return targetList;
  }

  List<Map<String, dynamic>> getVipPayMethodList({
    VipTypeBean? bean,
    List<VipTypeBean>? vipList,
  }) {
    final VipTypeBean? targetBean =
        bean ?? _currentVipPackage(vipList: vipList);
    return _buildPayMethodList(
      _resolveVipPayConfig(bean: targetBean, vipList: vipList),
      payOrderKey: targetBean?.payTypes,
    );
  }

  int getPayMethodIndex(
    List<Map<String, dynamic>> payList, {
    String? payMethodKey,
  }) {
    if (payList.isEmpty) {
      return 0;
    }
    final String targetPayMethod = payMethodKey ?? currentPayMethod;
    final int matchIndex = payList.indexWhere(
      (item) =>
          _isSamePayMethodKey(item["payNameKey"] as String?, targetPayMethod),
    );
    if (matchIndex >= 0) {
      return matchIndex;
    }
    return 0;
  }

  void refreshVipPayMethods({VipTypeBean? bean, List<VipTypeBean>? vipList}) {
    payMethodBeans = getVipPayMethodList(bean: bean, vipList: vipList);
    if (payMethodBeans.isEmpty) {
      currentPayMethodIndex.value = 0;
      currentPayMethod = '';
      return;
    }
    final int nextIndex = getPayMethodIndex(payMethodBeans);
    currentPayMethodIndex.value = nextIndex;
    currentPayMethod = payMethodBeans[nextIndex]["payNameKey"];
  }

  /// 添加支付方式
  void _addPayMethod(List<Map<String, dynamic>> targetList, String payType) {
    switch (payType) {
      case "wxpay":
        targetList.add({
          "payName": "微信支付",
          "payLabel": "微信",
          "icon": "assets/pay/wechat_pay.png",
          "payNameKey": "wxpay",
        });
        break;
      case "alipay":
        targetList.add({
          "payName": "支付宝支付",
          "payLabel": "支付宝",
          "icon": "assets/pay/ali_pay.png",
          "payNameKey": "alipay",
        });
        break;
      case "yeepay":
        // 检查是否已经添加了微信支付
        bool hasWxPay = targetList.any((bean) => bean["payNameKey"] == "wxpay");
        if (!hasWxPay) {
          targetList.add({
            "payName": "微信支付",
            "payLabel": "微信",
            "icon": "assets/pay/wechat_pay.png",
            "payNameKey": "yeepay",
          });
        }
        break;
      case "bank_subscribe":
        targetList.add({
          "payName": "银行卡支付",
          "payLabel": "银行卡",
          "icon": "assets/pay/balance_pay.png",
          "payNameKey": 'bank_subscribe',
        });
        break;

      case "zhongan_nopass":
        targetList.add({
          "payName": "支付宝支付",
          "payLabel": "支付宝",
          "icon": "assets/pay/ali_pay.png",
          "payNameKey": 'zhongan_nopass',
        });
        break;
    }
  }

  /// 切换支付方式
  void switchPayMethod(int index) {
    if (payType == 0) {
      if (index < 0 || index >= payMethodBeans.length) {
        return;
      }
      currentPayMethodIndex.value = index;
      currentPayMethod = payMethodBeans[index]["payNameKey"];
    } else {
      if (index < 0 || index >= wordPackagePayMethodBeans.length) {
        return;
      }
      currentWordPackagePayMethodIndex.value = index;
      currentPayMethod = wordPackagePayMethodBeans[index]["payNameKey"];
    }
    // update(['pay_select']);
    // update();
  }

  /*
    平台支付成功后
  */
  ///监听支付结果
  void payResult() {
    // paySuccessSubscription = eventBus.on<QueryOrderEvent>().listen((event) {
    //   Get.log(
    //     '__________监听订单status：${event.product.status}，——————$createOrderID,   ==>>${event.product.purchaseID}， ==>>${event.product.productID}}',
    //   );
    //   Get.log(
    //     '__________监听订单status===== >>>>>${event.product.status}：${event.product.verificationData.serverVerificationData}',
    //   );

    //   ///已经购买
    //   if (event.product.productID == createOrderID &&
    //       event.product.status == PurchaseStatus.purchased) {
    //     queryOrder(
    //       receiptData: event.product.verificationData.serverVerificationData,
    //     );
    //   }
    //   ///恢复购买
    //   else if (event.product.status == PurchaseStatus.restored) {
    //     createOrderID = '';
    //     orderRestore(event.product);
    //   }
    // });
  }

  ///vip订单查询
  void queryOrder({
    void Function()? onSuccess,
    void Function()? onFailed,
    String? receiptData,
    int retryCount = 0,
    bool showConfirmDialog = false,
  }) {
    if (orderID.isEmpty || isQuerying) {
      return;
    }
    Map<String, dynamic> params = {"id": orderID};
    final int maxRetryCount = 5;

    if (receiptData != null) {
      params["receipt_data"] = receiptData;
    }
    if (retryCount > maxRetryCount) {
      // showConfirmDialog();
      LoadingDialog().dismiss();
      onFailed?.call();
      if (showConfirmDialog) {
        _showBaofuQueryConfirmDialog();
      }
      return;
    }
    isQuerying = true;
    LoadingDialog().show(message: "订单查询中...");
    HttpUtils.post(
      payType == 0 ? NovelApis.orderQuery : NovelApis.tokenQuery,
      params,
      showMsgWhenFailed: false,
      success: (data) {
        isQuerying = false;
        byDebugPrint(data["data"], tag: "订单状态:");
        final String status = data["data"]["order_status"]?.toString() ?? "";
        final String msg = data["data"]["msg"]?.toString() ?? "";
        final bool isSubscribeOrder =
            data["data"]["is_subscribe"]?.toString() == "1";
        if (status == "SUCCESS") {
          LoadingDialog().dismiss();
          onSuccess?.call();
          successPay();
        } else if (status == "FAIL" ||
            (isSubscribeOrder &&
                status == "PAYING" &&
                (msg.contains("失败") || msg.contains("取消")))) {
          LoadingDialog().dismiss();
          onFailed?.call();
          if (msg.isNotEmpty) {
            Toast.showText(text: msg);
          }
        } else {
          Future.delayed(const Duration(seconds: 2), () {
            queryOrder(
              receiptData: receiptData,
              retryCount: retryCount + 1,
              showConfirmDialog: showConfirmDialog,
            );
          });
        }
      },
      fail: (code, msg) {
        isQuerying = false;
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }

  ///支付成功
  void successPay({bool isRestore = false}) {
    final UserController user = Get.find<UserController>();

    if (isRestore) {
      ///退出登录

      Get.find<LaunchController>().appLaunch();
      return;
    }

    _showSuccessDialog(
      onConfirm: () {
        if (user.isVisitor) {
          LoginManager.login(
            source: 'pay_success',
            binding: true,
            onSuccess: (_) {
              _refreshSuccessRelatedData(user);
              completePay?.call();
            },
          );
          return;
        }

        _refreshSuccessRelatedData(user);
        completePay?.call();
      },
    );
  }

  void _refreshSuccessRelatedData(UserController user) {
    user.reloadUserInfo(
      successAction: (_) {
        if (Get.isRegistered<IntergralRecordController>()) {
          Get.find<IntergralRecordController>().fetchCreditsItemList(true);
        }
      },
    );
  }

  /// 支付成功弹窗
  void _showSuccessDialog({VoidCallback? onConfirm}) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return Container(
          height: ByScreenUtils.screenHeight,
          alignment: .center,
          child: Container(
            height: 530.w,
            width: double.infinity,
            padding: EdgeInsets.only(left: 30.w, right: 30.w),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pay/icon_pay_success_bg.png'),
              ),
            ),
            child: Column(
              mainAxisAlignment: .end,
              mainAxisSize: .min,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    onConfirm?.call();
                  },
                  child: Container(
                    height: 48.w,
                    width: 260.w,
                    alignment: .center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.w),
                      gradient: LinearGradient(
                        colors: [Color(0xFFFC5D06), Color(0xFFFD8507)],
                      ),
                    ),
                    child: ByText.text(text: '我知道了', fontWeight: .bold),
                  ),
                ),
                SizedBox(height: 176.w),
              ],
            ),
          ),
        );
      },
    );
  }

  /*
    平台支付流程
  */
  ///开始支付
  void startPay({
    VipTypeBean? bean,
    String? payMethodKey,
    List<VipTypeBean>? vipList,
  }) {
    String resolvedPayMethod = payMethodKey ?? currentPayMethod;
    if (resolvedPayMethod.isEmpty) {
      final List<Map<String, dynamic>> availablePayList = payType == 0
          ? getVipPayMethodList(bean: bean, vipList: vipList)
          : wordPackagePayMethodBeans;
      if (availablePayList.isNotEmpty) {
        resolvedPayMethod = availablePayList.first["payNameKey"] ?? '';
      }
    }
    if (resolvedPayMethod.isEmpty) {
      Toast.showText(text: "暂无可用支付方式");
      return;
    }
    _getCreateOrderId(
      bean: bean,
      payMethodKey: resolvedPayMethod,
      vipList: vipList,
    );
  }

  ///获取创建会员套餐ID
  void _getCreateOrderId({
    VipTypeBean? bean,
    String? payMethodKey,
    List<VipTypeBean>? vipList,
  }) {
    dynamic package = bean;
    if (package == null) {
      if (payType == 0) {
        final list = vipList ?? payData.vipList;
        package = list[selectIndex.value];
      } else {
        package = payData.wordsPackageList[selectIndex.value];
      }
    }
    String packageID = package.id;
    createOrderID = package.id;
    if (Platform.isIOS) {
      createOrderID = package.appleVipId;
    }
    if (payType == 0 && package.userStatus != 0) {
      final UserController user = Get.find<UserController>();
      user.checkPreLogin(
        actionCallback: () {
          fetchOrderID(packageID, payMethodKey: payMethodKey);
        },
      );
    } else {
      fetchOrderID(packageID, payMethodKey: payMethodKey);
    }
  }

  ///获取套餐订单ID
  void fetchOrderID(String packageID, {String? payMethodKey}) async {
    final String resolvedPayMethod = payMethodKey ?? currentPayMethod;

    ///检查微信支付是否正常
    if (resolvedPayMethod == 'wxpay' || resolvedPayMethod == 'yeepay') {
      bool canWechatPay = await WechatKitPlatform.instance.isInstalled();
      if (!canWechatPay) {
        BotToast.showText(text: "由于您未安装微信，无法完成支付。请切换其他方式支付");
        return;
      }
    }
    if (resolvedPayMethod == 'alipay' ||
        resolvedPayMethod == 'zhongan_nopass') {
      // 支付宝支付
      bool canAliPay = await AlipayKitPlatform.instance.isInstalled();
      if (!canAliPay) {
        BotToast.showText(text: "由于您未安装支付宝，无法完成支付。请切换其他方式支付");
        return;
      }
    }

    LoadingDialog().show(message: '订单创建中...');

    HttpUtils.post(
      payType == 0 ? NovelApis.orderCreate : NovelApis.tokenCreate,
      showMsgWhenFailed: false,
      {
        "pay": resolvedPayMethod == 'yeepay' ? 'wxpay' : resolvedPayMethod,
        "config_id": packageID,
        "support_pays": payData.paySupport,
        // "pay_page_id": payData.pay_page_id
      },
      success: (data) {
        byDebugPrint(data["data"], tag: "创建支付订单:");
        orderID = data["data"]["id"];
        currentOrderCallMethod = data["data"]["call_method"]?.toString() ?? '';
        // platformPay();
        pullUpPayment(data['data']);
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
      },
    );
  }

  ///释放资源
  void dispose() {
    // paySuccessSubscription.cancel();
    cancelSubscribePayResult();
  }

  ///订单拉起支付
  void pullUpPayment(dynamic data) async {
    if (createOrderID.isEmpty) {
      Toast.showText(text: "没有该商品订单，请重试");
      LoadingDialog().dismiss();
      return;
    }
    if (Platform.isAndroid) {
      LoadingDialog().dismiss();
      if (data["call_method"] == "wxpay") {
        WxPayOrderBean payOrderBean = WxPayOrderBean.fromJson(data);
        PaymentUtil().wxPay(payOrderBean);
      } else if (data["call_method"] == "wxpay_mini") {
        YeepayPayOrderBean payOrderBean = YeepayPayOrderBean.fromJson(data);
        PaymentUtil().wxMiniProgramPay(payOrderBean);
      } else if (data["call_method"] == "alipay") {
        AliPayOrderBean aliPayOrderBean = AliPayOrderBean.fromJson(data);
        PaymentUtil().aliPay(aliPayOrderBean);
      } else if (data["call_method"] == "baofu") {
        await _handleBaofuSignFlow(data);
      } else if (data["call_method"] == "zhongan_nopass") {
        await _handleZhonganNoPassSignFlow(data);
      }
    } else if (Platform.isIOS) {
      LoadingDialog().show(message: '支付中...');
      // payEngine.loadProductDataAndBuy(createOrderID, orderID);
    }
  }

  /// 众安无密支付跳转银行卡支付页面
  /// 使用内部浏览器打开url
  Future<void> _handleZhonganNoPassSignFlow(dynamic data) async {
    final String? url = data["info"]['payUrl']?.toString();
    if (url != null && url.isNotEmpty) {
      final dynamic result = await ByNavRouterUtils.jumpWebViewPageResult(
        Get.context!,
        '',
        url,
        closeOnAppLinkPrefix: 'flashai://pay/query',
      );
      if (result is String && result.startsWith('flashai://pay/query')) {
        Get.log('zhongan_nopass_pay_applink: $result');
        queryOrder();
      }
    }
  }

  Future<void> _handleBaofuSignFlow(dynamic data) async {
    /// 宝付支付 跳转银行卡支付页面 需要传入订单号 id就是申请签约orderno
    ///
    EventTracking.reportDataPoint(
      pageTag: 'Purchase_click',
      operateType: 'click',
      funcDetailTag: '',
      funcDetailImg: '',
    );

    final String orderNo = data["id"]?.toString() ?? orderID;
    final dynamic signResult = await Get.toNamed(
      Routes.bankCardSelectPage,
      arguments: {'orderno': orderNo},
    );
    Get.log('baofu_sign_result: $signResult, orderID: $orderID');
    if (signResult == BankCardSignWebViewPage.successResult) {
      Get.log('baofu_sign_show_query_confirm_dialog');
      // _showBaofuQueryConfirmDialog();
      queryOrder(showConfirmDialog: true);
    }
  }

  void _showBaofuQueryConfirmDialog() {
    Get.dialog(
      NovelDialog(
        title: '温馨提示',
        content:
            '您好，当前付款人姓名较多，您的订单正在处理中，请稍后……如果您已经支付，请点击“我已支付”，如有其他疑问请点击“联系客服”处理',
        cancelText: '联系客服',
        confirmText: '我已支付',
        contentAlign: TextAlign.center,
        onCancel: () {
          if (Get.isRegistered<MainController>()) {
            Get.find<MainController>().openSupportl();
            return;
          }
          GlobalController.instance.config.goPrivacyPageWithTitle('在线客服');
        },
        onConfirm: () {
          Get.log('baofu_sign_manual_query_order');
          queryOrder();
        },
      ),
      barrierDismissible: false,
    );
  }

  /// 订阅支付结果
  void subscribePayResult() {
    if (Platform.isAndroid) {
      // 微信支付结果
      PaymentUtil().subscribeWXPayResp(
        Get.context!,
        onSuccess: () {
          // 支付成功,查询订单状态
          queryOrder();
        },
        onFailure: () {
          Get.log("支付失败或取消");
          BotToast.showText(text: "支付失败");
          LoadingDialog().dismiss();
        },
        onError: () {
          BotToast.showText(text: "支付异常");
          LoadingDialog().dismiss();
        },
      );

      // 支付宝支付结果
      PaymentUtil().subscribeAliPayResp(
        Get.context!,
        onSuccess: () {
          // 支付成功,查询订单状态
          queryOrder();
        },
        onFailure: () {
          Get.log("支付失败或取消");
          BotToast.showText(text: "支付失败");
          LoadingDialog().dismiss();
        },
        onError: () {
          BotToast.showText(text: "支付异常");
          LoadingDialog().dismiss();
        },
      );
    }
  }
}

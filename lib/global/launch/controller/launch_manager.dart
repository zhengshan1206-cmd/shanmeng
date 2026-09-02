import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:ling_bao/core/cache/byhy_aes_storage_utils.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/http_utils.dart';
import 'package:ling_bao/core/network/novel_apis.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/util/by_nav_router_utils.dart';
import 'package:ling_bao/global/const/consts.dart';
import 'package:ling_bao/global/pay/bean/integral_pay_list_bean.dart';
import 'package:ling_bao/global/pay/bean/vip_type_bean.dart';

import '../../const/const_string.dart';
import '../../user/user_menu_bean.dart';

class AppConfig extends GetxController {
  List protocolList = [];

  Map<String, String> normalKeyProtocal = {
    '用户协议': Consts.termsOfServiceUrl,
    '隐私政策': Consts.privacyPolicyUrl,
    '会员服务协议': Consts.seviceAgreement,
    '会员订阅协议': Consts.memberSubscriptionAgreement,
    '投诉举报': Consts.complaintReporting,
    '关于我们': Consts.aboutUs,
    '在线客服': Consts.feedback,
    '算法备案公示': Consts.algorithm,
  };

  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();

    ///添加默认项
    final List<String> titles = ['用户协议', '隐私政策', '会员服务协议', '会员订阅协议'];
    for (final title in titles) {
      protocolList.add(
        UserMenusBean(title: title, show: true, url: normalKeyProtocal[title]!),
      );
    }
  }

  ///获取协议列表
  void getProtocolList() {
    if (isLoading) {
      return;
    }
    HttpUtils.get(
      NovelApis.novelAppMenus,
      showMsgWhenFailed: false,
      {},
      success: (data) {
        // byDebugPrint(data, tag: "协议列表");
        isLoading = true;
        if (data != null && data['data'] != null) {
          List<dynamic> list = data['data'];
          protocolList = list.map((e) => UserMenusBean.fromJson(e)).toList();
        }
      },
    );
  }

  ///获取默认的协议页地址
  String _getNormalProtocal(String title) {
    if (normalKeyProtocal.containsKey(title)) {
      return normalKeyProtocal[title]!;
    }
    return Consts.termsOfServiceUrl;
  }

  /// 获取链接
  String getProtocalUrl(String title) {
    UserMenusBean? bean = protocolList.firstWhereOrNull(
      (element) => element.title == title,
    );
    if (bean == null) {
      return _getNormalProtocal(title);
    } else {
      return bean.url;
    }
  }

  ///跳转至指定协议页
  void goPrivacyPageWithTitle(String title) {
    try {
      UserMenusBean? bean = protocolList.firstWhereOrNull(
        (element) => element.title == title,
      );
      if (bean == null || bean.url.isEmpty) {
        ByNavRouterUtils.jumpWebViewPage(
          Get.context!,
          title,
          _getNormalProtocal(title),
        );
        return;
      }
      ByNavRouterUtils.jumpWebViewPage(Get.context!, title, bean.url);
    } catch (e) {
      // throw(e);
    }
  }
}

///付费页数据，包含套餐，运营位数据，字数包套餐，返回拦截弹窗数据
class PayData extends GetxController {
  ///底部须知说明
  RxString inform = ''.obs;

  ///vip套餐列表数据
  RxList<VipTypeBean> vipList = <VipTypeBean>[].obs;

  ///OB返回拦截套餐数据
  RxList<VipTypeBean> obList = <VipTypeBean>[].obs;

  ///vip套餐折扣数据
  RxList<VipTypeBean> vipDiscountList = <VipTypeBean>[].obs;

  ///vip套餐返回拦截列表数据
  RxList<VipTypeBean> vipInterceptList = <VipTypeBean>[].obs;

  ///字数包列表数据
  RxList<IntegralPayListBean> wordsPackageList = <IntegralPayListBean>[].obs;

  ///字数包协议
  String? wordsPackIllustrate = '';
  //支付方式支持
  String paySupport = Platform.isAndroid
      ? "wxpay,alipay,yeepay,baofu,zhongan_nopass"
      : "apple";

  ///vip支付方式配置
  Map<String, dynamic> payConfig = {'wxpay': 1, 'alipay': 1};

  ///字数包支付方式配置
  Map<String, dynamic> wordPackagePayConfig = {'wxpay': 1, 'alipay': 1};

  ///拦截弹窗支付方式配置
  Map<String, dynamic> retainPayConfig = {'wxpay': 1, 'alipay': 1};

  ///是否有免费试用
  RxBool hasTrial = true.obs;

  ///用户是否进入过vip页面
  bool hasEnteredVip = false;

  Rx<MultiStatusType> statusType = MultiStatusType.statusLoading.obs;

  bool loadIntercept = false;
  bool loadVip = false;
  bool loadWordPackage = false;

  @override
  void onInit() {
    super.onInit();
    getCacheData();
    // init();
  }

  ///获取初始本地化数据
  void getCacheData() {
    final String vipData = ByStorageUtils.getString(ConstString.kVipData) ?? '';
    if (vipData.isEmpty) {
      return;
    }
    final List vip = jsonDecode(vipData);
    List<VipTypeBean> typeBeans = vip
        .map((e) => VipTypeBean.fromJson(e as Map<String, dynamic>))
        .toList();
    // vipListCategory(typeBeans);
    vipList.clear();
    vipList.addAll(typeBeans);
    final String integralData =
        ByStorageUtils.getString(ConstString.kIntegralData) ?? '';
    if (integralData.isEmpty) {
      return;
    }
    final List integral = jsonDecode(integralData);
    List<IntegralPayListBean> beans = integral
        .map((e) => IntegralPayListBean.fromJson(e as Map<String, dynamic>))
        .toList();
    wordsPackageList.clear();
    wordsPackageList.addAll(beans);
  }

  void init({bool isReload = false, void Function(int)? onSuccess}) {
    _loadVipHappys(isReload: isReload, onSuccess: onSuccess);
    _loadWordPackageList(isReload: isReload, onSuccess: onSuccess);
    _loadVipHappys(isReload: isReload, onSuccess: onSuccess, vipType: 2);
  }

  ///获取VIP套餐与返回拦截套餐列表
  void _loadVipHappys({
    int vipType = 1,
    bool isReload = false,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    if (vipType == 1 && vipList.isNotEmpty && !isReload && loadVip) {
      return;
    }
    if (vipType == 2 && !isReload && loadIntercept) {
      return;
    }
    if (statusType.value != MultiStatusType.statusContent) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.vip,
      showMsgWhenFailed: false,
      {"ver": 2, "support_pays": paySupport, 'vip_type': vipType},
      success: (data) async {
        final respData = data["data"];
        final List items = respData["items"] ?? [];

        /// VIP套餐列表
        List<VipTypeBean> typeBeans = items
            .map((e) => VipTypeBean.fromJson(e))
            .toList();
        if (vipType == 1) {
          if (Platform.isAndroid) {
            try {
              payConfig = respData["data"]["pays"];
            } catch (e) {
              payConfig = {'wxpay': 1, 'alipay': 1};
            }
          }
          if (items.isNotEmpty) {
            ByStorageUtils.saveString(ConstString.kVipData, jsonEncode(items));
          }
          vipList.clear();
          vipList.addAll(typeBeans);
          statusType.value = MultiStatusType.statusContent;
          onSuccess?.call(0);
          loadVip = true;
        }
        ///vip返回拦截套餐
        else {
          if (Platform.isAndroid) {
            try {
              retainPayConfig = respData["data"]["pays"];
            } catch (e) {
              retainPayConfig = {'wxpay': 1, 'alipay': 1};
            }
          }
          loadIntercept = true;
          vipInterceptList.clear();
          vipInterceptList.addAll(typeBeans);
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        onFailed?.call();
      },
    );
  }

  /// 获取字数包列表
  void _loadWordPackageList({
    bool isReload = false,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    if (wordsPackageList.isNotEmpty && !isReload && loadWordPackage) {
      return;
    }
    HttpUtils.get(
      NovelApis.token,
      {"ver": 2, "support_pays": paySupport, "source_type": 1},
      showMsgWhenFailed: false,
      success: (data) async {
        final List items = data["data"]["items"] ?? [];
        wordsPackIllustrate = data["data"]["words_pack_illustrate"];

        /// 字数包套餐列表
        List<IntegralPayListBean> typeBeans = items
            .map((e) => IntegralPayListBean.fromJson(e))
            .toList();
        if (Platform.isAndroid) {
          try {
            wordPackagePayConfig = data["data"]["pays"];
          } catch (e) {
            wordPackagePayConfig = {'wxpay': 1, 'alipay': 1};
          }
        }
        ByStorageUtils.saveString(ConstString.kIntegralData, jsonEncode(items));
        wordsPackageList.clear();
        wordsPackageList.addAll(typeBeans);
        loadWordPackage = true;
        onSuccess?.call(1);
      },
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }

  /// 获取单个套餐数据
  /// [type] 1:OB返回拦截套餐, 2:vip套餐折扣
  void loadPackageData({
    required String id,
    required int type,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.get(
      APIs.getVipHappy,
      {"ver": 1, "support_pays": paySupport, "id": id},
      showMsgWhenFailed: false,
      success: (data) async {
        final Map<String, dynamic> item = data["data"] ?? {};
        if (item.isEmpty) {
          return;
        }
        wordsPackIllustrate = data["data"]["words_pack_illustrate"] ?? "";
        VipTypeBean bean = VipTypeBean.fromJson(item);
        if (type == 1) {
          //OB返回拦截套餐
          obList.clear();
          obList.add(bean);
        } else if (type == 2) {
          //vip套餐折扣
          vipDiscountList.clear();
          vipDiscountList.add(bean);
        }
        onSuccess?.call(1);
      },
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }
}

// 全局依赖注入绑定
class GlobalBinding implements Bindings {
  @override
  void dependencies() {
    // 注册全局控制器
    Get.put(GlobalController());

    // 注册各模块控制器
    Get.put(PayData());

    // 注册app配置控制器
    Get.put(AppConfig());
  }
}

class BannerManager {
  ///小说正文页
  bool novelDetailBanner = false;

  ///支付成功页
  Rx<bool> paySuccessBanner = false.obs;
}

// 全局状态管理类
class GlobalController extends GetxController {
  // 单例模式
  static GlobalController get instance => Get.find();

  ///支付相关数据
  PayData get pay => Get.find();

  ///配置相关
  AppConfig get config => Get.find();

  BannerManager banner = BannerManager();

  ///是否是首次进入
  bool isFirstIn = false;

  void init() {
    pay.init();
    config.getProtocolList();
  }

  // // 初始化 - 从本地加载数据
  // @override
  // void onInit() {
  //   super.onInit();
  // }
}

/*
 * @Author: cold-x
 * @Date: 2025-06-09 11:08:18
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-15 20:05:32
 * @FilePath: /ling_bao/lib/global/login/controller/onekey_manager.dart
 * @Description: 
 */

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/user/user.dart';
import 'package:shanyan/shanYanResult.dart';
import 'package:shanyan/shanYanUIConfig.dart';
import 'package:shanyan/shanyan.dart';
import '../../../core/service/debounce.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../routes/app_pages.dart';
import 'login_controller.dart';

class OneKeyManager {
  static final OneKeyManager _instance = OneKeyManager._internal();
  factory OneKeyManager() => _instance;
  OneKeyManager._internal();

  ///防抖
  final debouncer = Debouncer(milliseconds: 2000);

  ///是否已经有预取号
  bool isInit = false;

  ///是否有拉取归因的付费页数据
  bool loadPay = false;

  ///统计取号失败次数
  final List<String> failedList = [
    'first',
    'second',
    'third',
    'fourth',
    'fifth',
    'more',
  ];
  String failedString = 'first';

  ShanYanUIConfig shanYanUI = ShanYanUIConfig();

  ///闪验初始化
  static void init({bool? checkLogin = true}) {
    ///已经初始化
    if (_instance.isInit) {
      return;
    }

    if (checkLogin!) {
      final UserController user = Get.find<UserController>();

      ///用户已登录并且是检查登录状态
      if (user.userInfoBean.value != null && !user.isVisitor) {
        return;
      }
    }

    OneKeyLoginManager oneKeyLoginManager = OneKeyLoginManager();
    String appID = 'H4mxXNwR';
    if (Platform.isIOS) {
      appID = '9TVT0w0K';
    }
    oneKeyLoginManager.init(appId: appID).then((shanYanResult) {
      final code = shanYanResult.code;
      final result = shanYanResult.message;
      final content = shanYanResult.toJson().toString();

      print("________闪验初始化：：：code:$code,,content:$content,,result: $result");
      if (code == 1000) {
        ///预取号
        oneKeyLoginManager.getPhoneInfo().then((ShanYanResult shanYanResult) {
          print(
            "______________闪验结果：：：code:${shanYanResult.code},${shanYanResult.message},${shanYanResult.innerCode},${shanYanResult.innerDesc},${shanYanResult.token}",
          );
          if (shanYanResult.code == 1000) {
            _instance.isInit = true;
            print('________$shanYanResult');
          } else {
            int index =
                _instance.failedList.indexOf(_instance.failedString) + 1;
            if (index >= _instance.failedList.length) {
              index--;
            }
            _instance.failedString = _instance.failedList[index];
            print('________预取号失败}');
          }
        });
      } else {
        print('________闪验初始化失败}');
      }
    });
    // if(Platform.isAndroid) {
    //   _instance.initAuthUI(oneKeyLoginManager);
    // }
    // else if(Platform.isIOS) {
    //   _instance.initIOSAuthUI(oneKeyLoginManager);
    // }
  }

  static void onekeyLogin({
    bool? isBindMode = false,
    String? source = 'normal',
    bool? showClose = true,
    VoidCallback? successLogin,
    Function(String)? onSuccess,
    Function()? failed,
  }) {
    _instance.getPayStyle();

    ///防抖设置
    _instance.debouncer.run(() {
      ///预取号失败时调用手机号码登录
      if (!_instance.isInit) {
        _instance.authPullFailed(
          failed: failed,
          showClose: showClose,
          isBindMode: isBindMode,
          successLogin: successLogin,
          source: source,
        );
        return;
      }
      OneKeyLoginManager oneKeyLoginManager = OneKeyLoginManager();
      if (Platform.isAndroid) {
        _instance.initAuthUI(
          oneKeyLoginManager,
          isBind: false,
          showClose: showClose!,
        );
      } else if (Platform.isIOS) {
        _instance.initIOSAuthUI(
          oneKeyLoginManager,
          isBind: isBindMode!,
          showClose: showClose!,
        );
      }

      ///拉起授权页
      oneKeyLoginManager.openLoginAuth().then((data) {
        print('________拉起授权页${data.code}___${data.message}');
        if (1000 == data.code) {
          ///监听授权页事件
          oneKeyLoginManager.setOneKeyLoginListener((data) {
            print('________监听授权页事件${data.code}___${data.message}');
            if (1000 == data.code) {
              oneKeyLoginManager.finishAuthControllerCompletion();
              final String token = data.token.toString();
              final LoginController loginC = Get.isRegistered<LoginController>()
                  ? Get.find<LoginController>()
                  : Get.put(LoginController());
              loginC.isBindMode.value = isBindMode ?? false;
              loginC.onLoginSuccessCallback = successLogin;
              if (isBindMode!) {
                loginC.bindPhone(smsToken: token, isOnekey: true);
              } else {
                loginC.oneclickv2(token);
              }
              onSuccess?.call(token);
              // ///一键登录获取token成功
            } else if (1011 == data.code) {
              ///点击返回/取消 （强制自动销毁）
              oneKeyLoginManager.finishAuthControllerCompletion();
            } else {
              ///一键登录获取token失败
              //关闭授权页
              oneKeyLoginManager.finishAuthControllerCompletion();
            }
          });
        } else {
          print('________拉起授权页失败');
          _instance.authPullFailed(
            failed: failed,
            showClose: showClose,
            isBindMode: isBindMode,
            successLogin: successLogin,
            source: source,
          );
        }

        ///授权自定义页面事件
        oneKeyLoginManager.addClikWidgetEventListener((eventId) {
          switch (eventId) {
            ///手机登录
            case "phone_login":
              _instance.authPullFailed(
                failed: failed,
                showClose: showClose,
                successLogin: successLogin,
                isBindMode: isBindMode,
                source: source,
              );
              break;

            ///游客购买
            case "pay_btn":
              Get.find<UserController>().clearPendingAction();
              Get.find<UserController>().jumpToPayPage(source: source!);
              break;

            ///返回
            case "back":
              oneKeyLoginManager.finishAuthControllerCompletion();
              break;
          }
        });

        // oneKeyLoginManager.setAuthPageActionListener((AuthPageActionEvent authPageActionEvent) {
        // Map map = authPageActionEvent.toMap();
        ///点击一键登录未勾选隐私协议
        // if (map['type'] == 3 && map['code'] == 0) {
        //     BotToast.showText(text: '请勾选协议');
        //     showDialog(
        //       context: Get.context!,
        //       builder: (context) {
        //         return LoginAgreementView(
        //           callback: () {
        //             _instance.shanYanUI.androidPortrait.setPrivacyState = false;
        //           },
        //         );
        //       },
        //     );
        //   }
        // });
      });
    });
  }

  ///拉取付费页展示支付页页面类型数据(用于归因)
  void getPayStyle() {
    if (_instance.loadPay) {
      return;
    }
    // GlobalController.instance.pay.getPayStyle(onSuccess: () {
    //   _instance.loadPay = true;
    // },);
  }

  ///授权页拉取失败
  void authPullFailed({
    Function()? failed,
    bool? isBindMode,
    String? source = 'normal',
    bool? showClose,
    VoidCallback? successLogin,
  }) {
    Get.toNamed(
      Routes.login,
      arguments: {
        "isBind": isBindMode,
        "showClose": showClose,
        "onLoginSuccess": successLogin,
      },
    );
    failed?.call();
  }

  ///初始化闪验授权页UI
  void initAuthUI(
    OneKeyLoginManager oneKeyLoginManager, {
    bool isBind = false,
    bool showClose = true,
  }) {
    String color = '#FD2B54';
    ShanYanUIConfig shanYanUIConfig = _instance.shanYanUI;
    shanYanUIConfig.androidPortrait.isFinish = false;
    shanYanUIConfig.androidPortrait.setFullScreen = false;

    shanYanUIConfig.androidPortrait.setStatusBarColor = '#FFFFFF';
    shanYanUIConfig.androidPortrait.setLightColor = true;

    /// 导航栏
    shanYanUIConfig.androidPortrait.setNavReturnImgPath = "login_dialog_close";
    shanYanUIConfig.androidPortrait.setNavReturnImgHidden = !showClose;
    shanYanUIConfig.androidPortrait.setNavReturnBtnWidth = 32;
    shanYanUIConfig.androidPortrait.setNavReturnBtnHeight = 32;
    shanYanUIConfig.androidPortrait.setNavReturnBtnOffsetX = 12;
    // shanYanUIConfig.androidPortrait.setNavTextSize = 16;
    shanYanUIConfig.androidPortrait.setNavText = " ";
    // shanYanUIConfig.androidPortrait.setNavTextBold = true;
    // shanYanUIConfig.androidPortrait.setAuthNavHidden = true;
    shanYanUIConfig.androidPortrait.setAuthNavTransparent = true;
    shanYanUIConfig.androidPortrait.setAuthBGImgPath = "dengludialog_bj";

    ///logo
    shanYanUIConfig.androidPortrait.setLogoImgPath = "icon";
    shanYanUIConfig.androidPortrait.setLogoWidth = 80;
    shanYanUIConfig.androidPortrait.setLogoHeight = 80;
    shanYanUIConfig.androidPortrait.setLogoOffsetY = 80;
    shanYanUIConfig.androidPortrait.setLogoOffsetX = 147;

    ///隐私协议
    shanYanUIConfig.androidPortrait.setPrivacySmhHidden = false;
    shanYanUIConfig.androidPortrait.setPrivacyWidth = 350;
    shanYanUIConfig.androidPortrait.setPrivacyTextSize = 12;
    shanYanUIConfig.androidPortrait.setPrivacyWidth = 500;
    shanYanUIConfig.androidPortrait.setAppPrivacyColor = ["#808080", "#FFFFFF"];
    shanYanUIConfig.androidPortrait.setPrivacyOffsetX = 24;
    shanYanUIConfig.androidPortrait.setPrivacyOffsetGravityLeft = true;

    shanYanUIConfig.androidPortrait.setUncheckedImgPath = "unchecked";
    shanYanUIConfig.androidPortrait.setCheckedImgPath = "checked";
    shanYanUIConfig.androidPortrait.setCheckBoxWH = [14, 14];

    shanYanUIConfig.androidPortrait.setAppPrivacyOne = [
      "用户协议",
      GlobalController.instance.config.getProtocalUrl('用户协议'),
    ];
    shanYanUIConfig.androidPortrait.setAppPrivacyTwo = [
      "隐私政策",
      GlobalController.instance.config.getProtocalUrl('隐私政策'),
    ];

    /// 是否勾选协议
    shanYanUIConfig.androidPortrait.setPrivacyState =
        !Get.find<UserController>().isAudit();
    shanYanUIConfig.androidPortrait.setCheckBoxHidden =
        !Get.find<UserController>().isAudit();
    shanYanUIConfig.androidPortrait.setCheckBoxTipDisable = false;
    shanYanUIConfig.androidPortrait.setPrivacyCustomToastText = '请勾选下方协议';
    // shanYanUIConfig.androidPortrait.setPrivacyOffsetBottomY=-20;
    shanYanUIConfig.androidPortrait.setPrivacyText = ["我已阅读并同意", "和", " "];
    int succWidth = ByScreenUtils.screenWidth.toInt();
    int succHeight = ByScreenUtils.screenHeight.toInt();
    shanYanUIConfig.androidPortrait.setDialogTheme = [
      succWidth.toString(),
      // window.physicalSize.width.toString(),
      // double.infinity.toString(),
      succHeight.toString(),
      "0",
      "0",
      "true",
    ];

    ///手机号
    shanYanUIConfig.androidPortrait.setNumFieldOffsetY = 260;
    shanYanUIConfig.androidPortrait.setNumberSize = 32;
    shanYanUIConfig.androidPortrait.setNumberColor = '#FFFFFF';

    ///一键登录按钮
    shanYanUIConfig.androidPortrait.setLogBtnTextSize = 16;
    shanYanUIConfig.androidPortrait.setLogBtnWidth = 320;
    shanYanUIConfig.androidPortrait.setLogBtnOffsetY = 320;
    shanYanUIConfig.androidPortrait.setLogBtnTextBold = true;
    shanYanUIConfig.androidPortrait.setLogBtnTextColor = '#FFFFFF';
    shanYanUIConfig.androidPortrait.setLogBtnHeight = 48;
    shanYanUIConfig.androidPortrait.setLogBtnTextSize = 16;
    shanYanUIConfig.androidPortrait.setLogBtnBackgroundColor = color;

    shanYanUIConfig.androidPortrait.setLogoHidden = false;
    shanYanUIConfig.androidPortrait.setBackPressedAvailable = true;
    shanYanUIConfig.androidPortrait.setSloganHidden = true;
    shanYanUIConfig.androidPortrait.setActivityTranslateAnim = [
      "translate_in_bottom",
      "translate_out_bottom",
    ];

    //自定义按钮
    List<ShanYanCustomWidget> shanyanCustomWidgetAndroid = [];

    const String appSloganID1 = "app_slogan1"; // 标识控件 id
    ShanYanCustomWidget appSlogan1 = ShanYanCustomWidget(
      appSloganID1,
      ShanYanCustomWidgetType.TextView,
    );
    appSlogan1.textAlignment = ShanYanCustomWidgetGravityType.left;
    appSlogan1.textContent = "${isBind ? '绑定' : '登录'}解锁0基础写小说";
    appSlogan1.top = 90;
    appSlogan1.left = 116;
    appSlogan1.textColor = "#98FC4A";
    appSlogan1.textFont = 18;
    appSlogan1.isFinish = false;
    // shanyanCustomWidgetAndroid.add(appSlogan1);

    //logoSlogan
    ShanYanCustomWidget appSlogan = ShanYanCustomWidget(
      "app_slogan",
      ShanYanCustomWidgetType.TextView,
    );
    appSlogan.backgroundImgPath = 'welcome';
    appSlogan.top = 185;
    appSlogan.left = 118;
    appSlogan.width = 139;
    appSlogan.height = 20;
    appSlogan.isFinish = false;
    shanyanCustomWidgetAndroid.add(appSlogan);

    ShanYanCustomWidget phoneLogin = ShanYanCustomWidget(
      "phone_login",
      ShanYanCustomWidgetType.Button,
    );
    phoneLogin.textContent = "其他手机号登录";
    phoneLogin.top = 380;
    phoneLogin.left = 24;
    phoneLogin.right = 24;
    phoneLogin.textColor = "#80FFFFFF";
    phoneLogin.backgroundColor = '#000F0F12';
    phoneLogin.isFinish = true;
    phoneLogin.textAlignment = ShanYanCustomWidgetGravityType.center;
    shanyanCustomWidgetAndroid.add(phoneLogin);

    ///绑定手机号时
    // if (!isBind) {
    //   ///开启游客购买时
    //   if (Get.find<LaunchController>().launchInfo?.config?.allowTouristsVip ==
    //       1) {
    //     const String payString = "pay_btn"; // 标识控件 id
    //     ShanYanCustomWidget payBtn = ShanYanCustomWidget(
    //       payString,
    //       ShanYanCustomWidgetType.Button,
    //     );
    //     payBtn.textContent = "不登录直接购买";
    //     payBtn.top = 0;
    //     payBtn.height = 40;
    //     payBtn.right = 24;
    //     payBtn.textColor = "#80FFFFFF";
    //     payBtn.backgroundColor = '#00FFFFFF';
    //     payBtn.isFinish = true;
    //     payBtn.textAlignment = ShanYanCustomWidgetGravityType.right;
    //     shanyanCustomWidgetAndroid.add(payBtn);
    //   }
    // } else {
    //   const String phoneBindingString = "binding_phone"; // 标识控件 id
    //   ShanYanCustomWidget phoneBinding = ShanYanCustomWidget(
    //     phoneBindingString,
    //     ShanYanCustomWidgetType.Button,
    //   );
    //   phoneBinding.textContent = "*绑定账户后，可在任何设备恢复已购内容";
    //   phoneBinding.top = 345;
    //   phoneBinding.left = 24;
    //   phoneBinding.right = 24;
    //   phoneBinding.textColor = "#80FFFFFF";
    //   phoneBinding.backgroundColor = '#0F0F12';
    //   phoneBinding.isFinish = true;
    //   phoneBinding.textAlignment = ShanYanCustomWidgetGravityType.center;
    //   shanyanCustomWidgetAndroid.add(phoneBinding);
    // }

    shanYanUIConfig.androidPortrait.widgets = shanyanCustomWidgetAndroid;

    oneKeyLoginManager.setAuthThemeConfig(uiConfig: shanYanUIConfig);
  }

  void initIOSAuthUI(
    OneKeyLoginManager oneKeyLoginManager, {
    bool isBind = false,
    bool showClose = true,
  }) {
    ShanYanUIConfig shanYanUIConfig = _instance.shanYanUI;
    /*iOS 页面样式设置*/
    shanYanUIConfig.ios.isFinish = true;
    shanYanUIConfig.ios.setAuthBGImgPath = "dengludialog_bj";

    shanYanUIConfig.ios.setPreferredStatusBarStyle =
        iOSStatusBarStyle.styleLightContent;
    shanYanUIConfig.ios.setStatusBarHidden = false;
    shanYanUIConfig.ios.setAuthNavHidden = true;

    shanYanUIConfig.ios.setLogoImgPath = "icon";
    shanYanUIConfig.ios.setLogoCornerRadius = 16;
    shanYanUIConfig.ios.setLogoHidden = false;

    shanYanUIConfig.ios.setNumberColor = "#FFFFFF";
    shanYanUIConfig.ios.setNumberSize = 32;
    shanYanUIConfig.ios.setNumberBold = true;
    shanYanUIConfig.ios.setNumberTextAlignment = iOSTextAlignment.right;

    shanYanUIConfig.ios.setLogBtnText = "本机号码一键${!isBind ? '登录' : '绑定'}";
    shanYanUIConfig.ios.setLogBtnTextColor = "#000000";
    shanYanUIConfig.ios.setLoginBtnTextSize = 17;
    shanYanUIConfig.ios.setLoginBtnTextBold = true;
    shanYanUIConfig.ios.setLoginBtnBgColor = "#98FC4A";
    //    shanYanUIConfig.ios.setLoginBtnNormalBgImage = "2-0btn_15";
    //    shanYanUIConfig.ios.setLoginBtnHightLightBgImage = "圆角矩形 2 拷贝";
    //    shanYanUIConfig.ios.setLoginBtnDisabledBgImage = "login_btn_normal";
    shanYanUIConfig.ios.setLoginBtnCornerRadius = 15;

    shanYanUIConfig.ios.setPrivacyTextSize = 10;
    shanYanUIConfig.ios.setPrivacyTextBold = false;
    shanYanUIConfig.ios.setAppPrivacyTextAlignment = iOSTextAlignment.center;
    shanYanUIConfig.ios.setPrivacySmhHidden = true;
    shanYanUIConfig.ios.setAppPrivacyLineSpacing = 5;
    shanYanUIConfig.ios.setAppPrivacyNeedSizeToFit = false;
    //    shanYanUIConfig.ios.setAppPrivacyLineFragmentPadding = 10;
    shanYanUIConfig.ios.setAppPrivacyAbbreviatedName = "666";
    shanYanUIConfig.ios.setAppPrivacyColor = ["#808080", "#98FC4A"];

    shanYanUIConfig.ios.setAppPrivacyNormalDesTextFirst = "我已阅读并同意";
    //    shanYanUIConfig.ios.setAppPrivacyTelecom = "中国移动服务协议";
    shanYanUIConfig.ios.setAppPrivacyNormalDesTextSecond = "和";
    shanYanUIConfig.ios.setAppPrivacyFirst = [
      "《用户协议》",
      GlobalController.instance.config.getProtocalUrl('用户协议'),
    ];
    shanYanUIConfig.ios.setAppPrivacyNormalDesTextThird = "";
    shanYanUIConfig.ios.setAppPrivacySecond = [
      "《隐私政策》",
      GlobalController.instance.config.getProtocalUrl('隐私政策'),
    ];
    shanYanUIConfig.ios.setAppPrivacyNormalDesTextLast = "";

    shanYanUIConfig.ios.setAppPrivacyWebPreferredStatusBarStyle =
        iOSStatusBarStyle.styleDefault;
    shanYanUIConfig.ios.setAppPrivacyWebNavigationBarStyle =
        iOSBarStyle.styleDefault;

    //运营商品牌标签("中国**提供认证服务")
    shanYanUIConfig.ios.setSloganTextHidden = true;

    //供应商品牌标签("创蓝253提供认技术支持")
    shanYanUIConfig.ios.setShanYanSloganHidden = true;

    shanYanUIConfig.ios.setCheckBoxHidden = !Get.find<UserController>()
        .isAudit();
    shanYanUIConfig.ios.setPrivacyState = !Get.find<UserController>().isAudit();
    shanYanUIConfig.ios.setCheckBoxVerticalAlignmentToAppPrivacyTop = true;
    // shanYanUIConfig.ios.setCheckBoxVerticalAlignmentToAppPrivacyCenterY = true;
    shanYanUIConfig.ios.setUncheckedImgPath = "unchecked";
    shanYanUIConfig.ios.setCheckedImgPath = "checked";
    shanYanUIConfig.ios.setCheckBoxWH = [12, 12];
    // shanYanUIConfig.ios.setCheckBoxImageEdgeInsets = [2,2,2,2];

    shanYanUIConfig.ios.setLoadingCornerRadius = 10;
    shanYanUIConfig.ios.setLoadingBackgroundColor = "#E68147";
    shanYanUIConfig.ios.setLoadingTintColor = "#1C7EFF";

    shanYanUIConfig.ios.setShouldAutorotate = false;
    shanYanUIConfig.ios.supportedInterfaceOrientations =
        iOSInterfaceOrientationMask.all;
    shanYanUIConfig.ios.preferredInterfaceOrientationForPresentation =
        iOSInterfaceOrientation.portrait;

    //    shanYanUIConfig.ios.setAuthTypeUseWindow = false;
    //    shanYanUIConfig.ios.setAuthWindowCornerRadius = 10;

    shanYanUIConfig.ios.setAuthWindowModalTransitionStyle =
        iOSModalTransitionStyle.coverVertical;
    shanYanUIConfig.ios.setAuthWindowModalPresentationStyle =
        iOSModalPresentationStyle.fullScreen;
    shanYanUIConfig.ios.setAppPrivacyWebModalPresentationStyle =
        iOSModalPresentationStyle.fullScreen;
    shanYanUIConfig.ios.setAuthWindowOverrideUserInterfaceStyle =
        iOSUserInterfaceStyle.unspecified;

    shanYanUIConfig.ios.setAuthWindowPresentingAnimate = true;

    shanYanUIConfig.ios.setLoadingBackgroundColor = '#FF000000';
    shanYanUIConfig.ios.setLoadingTintColor = '#98FC4A';
    shanYanUIConfig.ios.setPrivacyNavTextColor = '#FFFFFF';
    shanYanUIConfig.ios.setAppPrivacyWebNavigationBarTintColor = '#0F0F12';

    //logo
    shanYanUIConfig.ios.layOutPortrait.setLogoTop = 164;
    shanYanUIConfig.ios.layOutPortrait.setLogoWidth = 80;
    shanYanUIConfig.ios.layOutPortrait.setLogoHeight = 80;
    shanYanUIConfig.ios.layOutPortrait.setLogoLeft = 24;
    //手机号控件
    shanYanUIConfig.ios.layOutPortrait.setNumFieldTop = 330;
    shanYanUIConfig.ios.layOutPortrait.setNumFieldCenterX = 0;
    shanYanUIConfig.ios.layOutPortrait.setNumFieldHeight = 40;
    shanYanUIConfig.ios.layOutPortrait.setNumFieldWidth = 300;
    //一键登录按钮
    shanYanUIConfig.ios.layOutPortrait.setLogBtnTop = 402;
    shanYanUIConfig.ios.layOutPortrait.setLogBtnLeft = 24;
    shanYanUIConfig.ios.layOutPortrait.setLogBtnHeight = 48;
    shanYanUIConfig.ios.layOutPortrait.setLogBtnRight = 24;

    ///***重要代码。删除拉不起授权，别问为什么，问就是surprise
    //授权页 创蓝slogan（创蓝253提供认证服务）
    shanYanUIConfig.ios.layOutPortrait.setShanYanSloganHeight = 15;
    shanYanUIConfig.ios.layOutPortrait.setShanYanSloganLeft = 0;
    shanYanUIConfig.ios.layOutPortrait.setShanYanSloganRight = 0;
    shanYanUIConfig.ios.layOutPortrait.setShanYanSloganBottom = 15;
    //授权页 slogan（***提供认证服务）
    shanYanUIConfig.ios.layOutPortrait.setSloganHeight = 15;
    shanYanUIConfig.ios.layOutPortrait.setSloganLeft = 0;
    shanYanUIConfig.ios.layOutPortrait.setSloganRight = 0;
    shanYanUIConfig.ios.layOutPortrait.setSloganBottom =
        shanYanUIConfig.ios.layOutPortrait.setShanYanSloganBottom! +
        shanYanUIConfig.ios.layOutPortrait.setShanYanSloganHeight!;

    ///***重要代码。删除拉不起授权，别问为什么，问就是surprise

    //隐私协议
    //    shanYanUIConfig.ios.layOutPortrait.setPrivacyHeight = 50;
    shanYanUIConfig.ios.layOutPortrait.setPrivacyLeft = 60;
    shanYanUIConfig.ios.layOutPortrait.setPrivacyRight = 60;
    shanYanUIConfig.ios.layOutPortrait.setPrivacyBottom =
        shanYanUIConfig.ios.layOutPortrait.setSloganBottom! +
        shanYanUIConfig.ios.layOutPortrait.setShanYanSloganHeight! +
        5;

    List<ShanYanCustomWidgetIOS> shanyanCustomWidgetIOS = [];

    const String appSloganID1 = "app_slogan1"; // 标识控件 id
    ShanYanCustomWidgetIOS appSlogan1 = ShanYanCustomWidgetIOS(
      appSloganID1,
      ShanYanCustomWidgetType.TextView,
    );
    appSlogan1.textAlignment = iOSTextAlignment.left;
    appSlogan1.textContent = "${isBind ? '绑定' : '登录'}解锁0基础写小说";
    appSlogan1.top = 175;
    appSlogan1.left = 116;
    appSlogan1.textColor = "#98FC4A";
    appSlogan1.textFont = 18;
    appSlogan1.isFinish = false;
    shanyanCustomWidgetIOS.add(appSlogan1);

    const String appSloganID = "app_slogan"; // 标识控件 id
    ShanYanCustomWidgetIOS appSlogan = ShanYanCustomWidgetIOS(
      appSloganID,
      ShanYanCustomWidgetType.TextView,
    );
    appSlogan.textAlignment = iOSTextAlignment.left;
    appSlogan.textContent = "赚钱秘籍";
    appSlogan.top = 205;
    appSlogan.left = 116;
    appSlogan.textColor = "#98FC4A";
    appSlogan.textFont = 24;
    appSlogan.isFinish = false;
    shanyanCustomWidgetIOS.add(appSlogan);


    const String phoneLoginID = "phone_login"; // 标识控件 id
    ShanYanCustomWidgetIOS phoneLogin = ShanYanCustomWidgetIOS(
      phoneLoginID,
      ShanYanCustomWidgetType.Button,
    );
    phoneLogin.textContent = "其他手机号${!isBind ? '登录' : '绑定'}";
    phoneLogin.top = !isBind ? 470 : 500;
    phoneLogin.left = 24;
    phoneLogin.right = 24;
    phoneLogin.textColor = "#FF98FC4A";
    phoneLogin.backgroundColor = '#0F0F12';
    phoneLogin.isFinish = true;
    phoneLogin.textAlignment = iOSTextAlignment.center;
    shanyanCustomWidgetIOS.add(phoneLogin);

    ///绑定手机号时
    // if (!isBind) {
    //   ///开启游客购买时
    //   if (Get.find<LaunchController>().launchInfo?.config?.allowTouristsVip ==
    //       1) {
    //     const String payString = "pay_btn"; // 标识控件 id
    //     ShanYanCustomWidgetIOS payBtn = ShanYanCustomWidgetIOS(
    //       payString,
    //       ShanYanCustomWidgetType.Button,
    //     );
    //     payBtn.textContent = "不登录直接购买";
    //     payBtn.top = 0;
    //     payBtn.height = 40;
    //     payBtn.right = 24;
    //     payBtn.textColor = "#80FFFFFF";
    //     // payBtn.backgroundColor = '#0F0F12';
    //     payBtn.isFinish = true;
    //     payBtn.textAlignment = iOSTextAlignment.right;
    //     shanyanCustomWidgetIOS.add(payBtn);
    //   }
    // } else {
    //   const String phoneBindingString = "binding_phone"; // 标识控件 id
    //   ShanYanCustomWidgetIOS phoneBinding = ShanYanCustomWidgetIOS(
    //     phoneBindingString,
    //     ShanYanCustomWidgetType.Button,
    //   );
    //   phoneBinding.textContent = "*注册账户后，可在任何设备恢复已购内容";
    //   phoneBinding.top = 470;
    //   phoneBinding.left = 24;
    //   phoneBinding.right = 24;
    //   phoneBinding.textColor = "#80FFFFFF";
    //   phoneBinding.backgroundColor = '#0F0F12';
    //   phoneBinding.isFinish = true;
    //   phoneBinding.textAlignment = iOSTextAlignment.center;
    //   shanyanCustomWidgetIOS.add(phoneBinding);
    // }

    const String backID = "back"; // 标识控件 id
    ShanYanCustomWidgetIOS backBtn = ShanYanCustomWidgetIOS(
      backID,
      ShanYanCustomWidgetType.Button,
    );
    backBtn.image = "login_dialog_close";
    backBtn.top = 60;
    backBtn.left = 12;
    backBtn.width = 40;
    backBtn.height = 40;
    backBtn.textColor = "#FFFFFF";
    backBtn.backgroundColor = '#00000000';
    backBtn.isFinish = true;
    backBtn.textAlignment = iOSTextAlignment.left;
    if (showClose) {
      shanyanCustomWidgetIOS.add(backBtn);
    }

    shanYanUIConfig.ios.widgets = shanyanCustomWidgetIOS;

    oneKeyLoginManager.setAuthThemeConfig(uiConfig: shanYanUIConfig);
  }
}

import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/service/app_permisson/byhy_permission_utils.dart';
import 'package:ling_bao/core/ui/dialog/by_dialog_util.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/ui/view/progress_bar.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/global/launch/controller/launch_controller.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/ui/colors.dart';

import '../../../core/cache/byhy_aes_storage_utils.dart';
import '../../const/const_string.dart';
import '../../routes/app_pages.dart';
import '../../user/user.dart';
import 'package:video_player/video_player.dart';
import '../../../main.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage>
    with TickerProviderStateMixin, RouteAware {
  final controller = Get.put(LaunchController(), permanent: true);
  final userController = Get.put(UserController(), permanent: true);
  late VideoPlayerController _videoController;

  ///网络连接状态监听
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isCoveredByRoute = false;
  Worker? _launchDialogWorker;
  Worker? _forcePauseVideoWorker;

  void _syncLaunchVideoState() {
    if (!_videoController.value.isInitialized) {
      return;
    }
    final bool shouldPause =
        _isCoveredByRoute || controller.forcePauseLaunchVideo.value;

    if (shouldPause) {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      }
    } else {
      if (!_videoController.value.isPlaying) {
        _videoController.play();
      }
    }
    // 启动视频全程静音，避免进入页面时外放。
    _videoController.setVolume(0.0);
  }

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/global/launch/launch.mp4', // 与 pubspec.yaml 配置一致
      // 可选配置：自动播放、循环、音量等
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true, // 是否允许与其他音频混合播放
      ),
    );
    _videoController.initialize().then((_) {
      if (!mounted) return;
      _syncLaunchVideoState();
    });
    _videoController.setLooping(true); // 循环播放
    _videoController.play();
    _launchDialogWorker = ever<int>(controller.launchDialogCount, (_) {
      _syncLaunchVideoState();
    });
    _forcePauseVideoWorker = ever<bool>(controller.forcePauseLaunchVideo, (_) {
      _syncLaunchVideoState();
    });

    if (controller.needNetworkAuth()) {
      _startListening();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkAgreement();
    });
  }

  // 初始化监听
  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  // 处理网络变化
  void _handleConnectivityChange(List<ConnectivityResult> result) {
    if (!result.contains(ConnectivityResult.none)) {
      controller.hasNetwork = true;
      controller.appLaunch();
    } else {
      // 恢复在线功能
      controller.hasNetwork = false;
      controller.payData.statusType.value = MultiStatusType.statusContent;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.unsubscribe(this);
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _launchDialogWorker?.dispose();
    _forcePauseVideoWorker?.dispose();
    super.dispose();
    _videoController.dispose();
    _subscription?.cancel();
  }

  @override
  void didPushNext() {
    _isCoveredByRoute = true;
    _syncLaunchVideoState();
  }

  @override
  void didPopNext() {
    _isCoveredByRoute = false;
    _syncLaunchVideoState();
  }

  @override
  void didPush() {
    _isCoveredByRoute = false;
    _syncLaunchVideoState();
  }

  @override
  void didPop() {
    _isCoveredByRoute = true;
    _syncLaunchVideoState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ByColor.colorBg1),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Positioned.fill(
              //   child: Image.asset(
              //     "assets/global/launch/launch_bg.png",
              //     fit: BoxFit.cover,
              //   ),
              // ),
              /// 启动页背景视频
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 720 / 1280,
                      child: VideoPlayer(_videoController),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 200.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ByColor.colorBg1.withAlphaValue(0.0),
                              ByColor.colorBg1,
                            ],
                            begin: .topCenter,
                            end: .bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 底部按钮
              Positioned(
                bottom: 50.w + ByScreenUtils.bottomSafeHeight,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/global/launch/launch_logo.png',
                      height: 100.w,
                    ),
                    SizedBox(height: 36.w),

                    Obx(
                      () => ByText.text(
                        text: controller.starCount.value >= 5 ? "" : '资源加载中...',
                        fontSize: 13.sp,
                        textColor: ByColor.colorF2,
                      ),
                    ),
                    SizedBox(height: 12.w),

                    Obx(
                      () => Offstage(
                        offstage: controller.starCount.value >= 5,
                        child: SizedBox(
                          height: 6.w,
                          width: 303.w,
                          child: Obx(
                            () => ProgressBar(
                              border: 3.w,
                              progress: min(
                                controller.timerCount.value / 250,
                                1.0,
                              ),
                              trackColor: Color(0xFF343C48).withAlphaValue(0.4),
                              progressGradiantColor: LinearGradient(
                                colors: [
                                  Color(0xFFFEFEFE),
                                  Color(0xFFF0FEE5),
                                  Color(0xFFFFC779),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!controller.hasGuide())
                      Obx(
                        () => Offstage(
                          offstage: controller.starCount.value < 5,
                          child: SizedBox(
                            height: 48.w,
                            width: width - 24.w,
                            child: Stack(
                              children: [
                                Obx(
                                  () => ByWidgetsUtil.gradientBtn(
                                    fontSize: 16.sp,
                                    fontWeight: .bold,
                                    title:
                                        controller.payData.statusType.value ==
                                            MultiStatusType.statusContent
                                        ? '下一步'
                                        : '重试',
                                    onClick: () {
                                      if (controller.payData.statusType.value ==
                                              MultiStatusType.statusContent &&
                                          controller.isLaunched.value) {
                                        ByStorageUtils.saveBool(
                                          ConstString.kLaunchGuideCheck,
                                          true,
                                        );
                                        if (userController.isVip) {
                                          Get.offAllNamed(Routes.main);
                                          return;
                                        }
                                        controller.gotoGuide();
                                      } else {
                                        if (controller.isLaunched.value) {
                                          GlobalController.instance.init();
                                        } else {
                                          if (controller
                                                  .payData
                                                  .statusType
                                                  .value ==
                                              MultiStatusType.statusNoNetWork) {
                                            ByDialogUtil.showPopScopeDialog(
                                              context: context,
                                              title: '网络异常',
                                              contents:
                                                  '无法连接服务器，请检查您的网络或者切换至其他网络',
                                              confirmBtnTitle: 'Settings',
                                              confirmCallback: () {
                                                /// 更新设置
                                                ByPermissionUtils.openPermissionSettings();
                                              },
                                              cancelBtnTitle: '重试',
                                              cancelCallback: () {
                                                controller
                                                    .payData
                                                    .statusType
                                                    .value = MultiStatusType
                                                    .statusLoading;
                                                Future.delayed(
                                                  Duration(seconds: 1),
                                                  () {
                                                    controller.appLaunch();
                                                  },
                                                );
                                              },
                                            );
                                          } else {
                                            controller
                                                    .payData
                                                    .statusType
                                                    .value =
                                                MultiStatusType.statusLoading;
                                            Future.delayed(
                                              Duration(seconds: 1),
                                              () {
                                                controller.appLaunch();
                                              },
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                                Obx(
                                  () =>
                                      controller.payData.statusType.value ==
                                          MultiStatusType.statusLoading
                                      ? Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 4.w,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20.w,
                                            ),
                                            color: ByColor.colorC1,
                                          ),
                                          child: Center(
                                            child: CupertinoActivityIndicator(
                                              color: ByColor.colorF8,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!controller.hasGuide())
                Obx(
                  () =>
                      [
                            MultiStatusType.statusNoNetWork,
                            MultiStatusType.statusLoading,
                          ].contains(controller.payData.statusType.value) &&
                          controller.starCount.value >= 5
                      ? Positioned(
                          bottom: 53.w + ByScreenUtils.bottomSafeHeight,
                          child: ByText.text(
                            fontSize: 12.sp,
                            textColor:
                                controller.payData.statusType.value ==
                                    MultiStatusType.statusNoNetWork
                                ? ByColor.colorG4
                                : ByColor.colorF1,
                            text:
                                controller.payData.statusType.value ==
                                    MultiStatusType.statusNoNetWork
                                ? '无法连接服务器，请检查您的网络或者切换至其他网络'
                                : '拉取配置信息，请稍候...',
                          ),
                        )
                      : Container(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

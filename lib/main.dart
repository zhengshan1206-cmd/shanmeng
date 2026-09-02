/*
 * @Author: cold-x
 * @Date: 2025-09-12 16:04:53
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-28 09:35:33
 * @FilePath: /ling_bao/lib/main.dart
 * @Description: 
 */

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ling_bao/core/cache/build_config.dart';
import 'package:ling_bao/core/cache/environment.dart';
import 'package:ling_bao/core/cache/environment_config.dart';
import 'package:ling_bao/core/network/channel.dart';
import 'package:ling_bao/core/service/app_translations.dart';
import 'package:ling_bao/global/initiliazation/app_life_circle.dart';
import 'package:ling_bao/global/initiliazation/initialize.dart';
import 'package:ling_bao/global/initiliazation/theme.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'global/routes/app_pages.dart';
import 'global/routes/navigator_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<dynamic>> routeObserver =
    RouteObserver<ModalRoute<dynamic>>();

Locale? language = Get.deviceLocale;

void main() async {
  BuildConfig.instantiate(
    envType: Environment.PRODUCTION,
    envConfig: EnvironmentConfig(),
    channelType: ChannelType.oppo,
  );

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // 强制竖屏
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// 全局注册app生命周期监听
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());

  ///app 初始化
  await InitializeManager.initializition();
  language = await LanguageService.getSavedLanguage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: InitializeManager.initRefresh(
        GetMaterialApp(
          title: '闪梦AI',
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          defaultTransition: Platform.isIOS
              ? Transition.cupertino
              : Transition.fadeIn,
          supportedLocales: const [
            Locale('zh', 'CN'), // 简体中文
            // Locale('en', 'US'),
            // Locale('ja', 'JP'),
          ],
          // 1. 配置翻译实例
          translations: AppTranslations(),
          // 2. 默认语言（未指定时使用）
          fallbackLocale: const Locale('zh', 'CN'),
          // 3. 初始语言（可选，不设置则跟随系统）
          // locale: language,
          locale: const Locale('zh', 'CN'),
          localizationsDelegates: [
            RefreshLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.launch,
          initialBinding: GlobalBinding(),
          builder: BotToastInit(),
          navigatorObservers: [
            // ToastNavigatorObserver(),
            routeObserver,
            GetObserver(),
            MyRouteObserver(),
            BotToastNavigatorObserver(),
          ],
        ),
      ),
    );
  }
}

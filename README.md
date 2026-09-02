# ling_bao

基于 Flutter 开发的移动端 AI 创作应用，当前主流程围绕 AI 图片广场、创作工作台、个人作品管理与会员/积分支付展开。项目使用 GetX 管理路由与状态，封装了统一网络层、缓存层、支付能力和一套通用 UI 组件。

## 项目概览

- 技术栈：`Flutter 3 / Dart 3 / GetX / Dio / ScreenUtil / BotToast`
- 端能力：`Android / iOS / Web / macOS / Windows / Linux`
- 当前入口：`lib/main.dart`
- 默认环境：启动时固定使用 `Environment.TEST` 和 `ChannelType.launchTest`
- 当前首页结构：底部仅启用 `AI 图片` 与 `创作` 两个 Tab，视频相关能力保留了独立模块和路由，但未作为首页主 Tab 打开

## 目录结构

以下为与业务最相关的目录，已省略 `build`、`.dart_tool`、平台自动生成文件等内容：

```text
.
├── assets/                     静态资源，按启动页 / 首页 / 支付 / 个人中心等拆分
├── lib/
│   ├── core/                   基础设施
│   │   ├── cache/              环境配置、本地缓存、加解密、日志
│   │   ├── common/             通用常量、事件、平台 channel、FFmpeg 工具
│   │   ├── network/            Dio 封装、接口定义、拦截器、错误处理、流式请求
│   │   ├── pay/                支付引擎、支付管理、订单模型
│   │   ├── service/            权限、本地化、日志、邮件、词汇服务
│   │   ├── ui/                 通用页面、弹窗、组件、音视频视图
│   │   └── util/               设备、路由、屏幕、下载、剪贴板等工具
│   ├── global/                 全局业务
│   │   ├── const/              全局常量
│   │   ├── initiliazation/     初始化、主题、应用生命周期
│   │   ├── launch/             启动页、隐私确认、引导流程、启动配置
│   │   ├── login/              微信/一键/手机验证码登录
│   │   ├── main/               应用主框架与底部导航
│   │   ├── other/              多语言、违禁词检测、权益管理
│   │   ├── pay/                会员/积分支付页与支付样式
│   │   ├── routes/             GetX 路由声明与页面映射
│   │   ├── ui/                 全局主题色和资源引用
│   │   └── user/               用户信息、前置登录、支付跳转
│   ├── create/                 AI 创作页、创作类型弹层、热门案例
│   ├── image/                  AI 图片首页、分类区块、图片广场
│   ├── profile/                个人中心、积分记录、作品详情
│   ├── video/                  AI 视频首页、详情、创作承接页
│   └── main.dart               应用入口
├── test/                       默认 Flutter widget test
├── android/                    Android 工程
├── ios/                        iOS 工程
├── macos/                      macOS 工程
├── linux/                      Linux 工程
├── windows/                    Windows 工程
└── web/                        Web 入口资源
```

## 启动链路

应用启动主流程集中在 `lib/main.dart`、`lib/global/initiliazation/initialize.dart` 和 `lib/global/launch/controller/launch_controller.dart`：

1. 初始化 `BuildConfig`，注入环境和渠道配置。
2. 锁定竖屏，注册应用生命周期监听。
3. 初始化本地存储、用户代理、时区、微信 SDK。
4. 启动页检查隐私协议、网络状态和本地缓存的启动配置。
5. 调用启动接口获取 token、启动配置、用户初始化数据。
6. 根据引导状态、会员状态和启动配置进入首页或支付页。

## 核心功能模块

### 1. 启动与全局初始化

- 启动页支持隐私协议确认、引导页、网络授权检查和本地启动信息缓存。
- 应用级初始化包含状态栏样式、下拉刷新全局配置、微信 SDK 注册。
- 全局绑定通过 `GetX` 注入启动控制器、用户控制器、支付状态等长期对象。

### 2. 登录与用户体系

- 支持微信登录、一键登录、手机号验证码登录。
- 支持游客态进入应用，部分动作通过前置登录机制拦截后继续执行。
- 用户信息会落地本地缓存，并在启动后或进入个人中心时刷新。
- 个人中心提供用户资料、ID 复制、设置页、客服入口和积分展示。

相关代码：

- `lib/global/login/controller/login_controller.dart`
- `lib/global/user/user.dart`
- `lib/profile/main/controller/profile_controller.dart`

### 3. 首页与导航框架

- 主框架位于 `lib/global/main/main_page.dart`。
- 当前底部导航启用了 `AI 图片` 和 `创作` 两个页面。
- `MainController` 负责启动数据检查、首页模块装载、支付页/个人中心/客服跳转以及页面停留时长上报。
- 视频模块控制器已存在，但主页视频 Tab 当前被注释保留。

### 4. AI 图片广场

- 首屏按分类拉取图片广场内容，并为每个分类加载作品列表。
- 顶部提供支付、客服、个人中心入口。
- 当前从图片首页可直接进入文生图创作，也可查看分类更多内容与案例详情。

相关代码：

- `lib/image/home_image_controller.dart`
- `lib/image/home_image_tab.dart`

### 5. AI 创作工作台

- 创作类型通过 `lib/create/home_create_type_dialog.dart` 统一管理。
- 已定义的创作流包括：
  - 图生视频
  - 文生视频
  - 首尾帧视频
  - 多图视频
  - AI 绘图
  - AI 修图
  - 参考图生图
- 支持图片选择与上传、尺寸校验、内容风险检测、违禁词检测、权益查询、提交生成任务。
- 生成成功后会跳转到个人中心查看作品。

相关代码：

- `lib/create/create_controller.dart`
- `lib/create/create_page.dart`
- `lib/create/home_create_page.dart`

### 6. 视频模块

- 项目保留了独立的视频首页、详情页和创作案例页。
- 目前视频模块更多作为创作结果展示和深度入口存在，不是首页默认主导航。
- 热门视频、视频创作、视频详情页路由均已接入。

相关代码：

- `lib/video/main/controller/home_video_controller.dart`
- `lib/video/main/controller/video_create_controller.dart`
- `lib/video/main/controller/video_detail_controller.dart`

### 7. 支付与权益体系

- 支持会员套餐和积分套餐两套支付模型。
- 支付方式覆盖：
  - Apple IAP
  - 微信支付
  - 支付宝
  - YeePay 通道映射
- 支付页样式和可用支付方式来自后端配置。
- 创作前会查询权益，不足时自动跳转到支付页。

相关代码：

- `lib/core/pay/pay_manager.dart`
- `lib/global/pay/controller/pay_controller.dart`
- `lib/global/pay/page/pay_center_page.dart`

## 基础设施设计

### 网络层

- 统一入口：`lib/core/network/http_utils.dart`
- 封装能力：GET/POST、轮询、统一错误处理、Loading、Toast、日志打印
- 拦截器：鉴权拦截、请求日志、响应状态统一处理
- 接口常量：`lib/core/network/apis.dart`

### 缓存与配置

- `core/cache` 负责环境配置、本地缓存、加密存储和日志开关。
- 用户数据、启动配置、版本号、语言等都通过本地缓存保存。
- 当前代码里入口环境固定为测试环境，如需发版需要结合 `BuildConfig` 与渠道配置切换。

### 通用 UI 与服务

- `core/ui` 提供弹窗、加载态、空态、多状态页、音视频播放器、通用按钮等基础组件。
- `core/service` 包含权限、本地化、日志、流式处理、邮件、违禁词等服务。
- `global/other/language` 已内置多语言资源文件，但主入口当前仅启用了 `zh_CN`。

## 主要路由

路由定义位于 `lib/global/routes/app_pages.dart` 和 `lib/global/routes/app_routes.dart`。

当前已注册的主要页面包括：

- 启动页 `Routes.launch`
- 首页 `Routes.main`
- 登录页 `Routes.login`
- 手机登录页 `Routes.loginPhone`
- 引导页 `Routes.guide`
- 个人中心 `Routes.userProfile`
- 创作页 `Routes.create`
- 支付中心 `Routes.payCenterPage`
- 积分记录页 `Routes.creditsItemList`
- 视频详情页 `Routes.videoDetail`
- 创作案例页 `Routes.caseCreate`

## 运行与开发

### 环境要求

- Flutter SDK：与 `pubspec.yaml` 中的 `sdk: ^3.10.4` 保持兼容
- 已配置 Android / iOS 开发环境
- 若需完整运行登录、支付、拉起第三方能力，需要补齐对应平台证书、URL Scheme、Universal Link、商店配置

### 常用命令

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

### 第三方能力

项目已接入或声明依赖以下原生能力，调试前需要确认平台配置完整：

- `wechat_kit`
- `alipay_kit`
- `in_app_purchase`
- `shanyan` 一键登录
- `image_picker` / `wechat_assets_picker` / `wechat_camera_picker`
- `video_player` / `audioplayers`

## 当前状态与维护建议

- `README` 已根据现有代码整理，但仓库中仍存在部分历史注释代码与暂未启用的页面分支。
- `lib/video` 模块和多语言资源是保留中的能力，当前首页主流程没有完全开放。
- `test/` 目录目前只有 Flutter 默认测试样例，业务模块缺少自动化测试覆盖。
- 仓库根目录包含 `.DS_Store`、`build/` 等本地或构建产物，建议后续清理并完善 `.gitignore`。

## 参考入口文件

- 应用入口：`lib/main.dart`
- 初始化：`lib/global/initiliazation/initialize.dart`
- 路由表：`lib/global/routes/app_pages.dart`
- 主页面：`lib/global/main/main_page.dart`
- 创作控制器：`lib/create/create_controller.dart`
- 支付管理：`lib/core/pay/pay_manager.dart`

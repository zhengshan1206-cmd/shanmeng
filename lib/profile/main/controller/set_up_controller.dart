import 'package:get/get.dart';
import 'package:ling_bao/profile/main/controller/profile_controller.dart';

import '../../../../global/login/controller/login_manager.dart';
import '../../../core/network/apis.dart';
import '../../../core/network/http_utils.dart';
import '../../../core/ui/dialog/by_dialog_util.dart';
import '../../../core/ui/dialog/toast.dart';
import '../../../global/launch/bean/launch_bean.dart';
import '../../../global/launch/controller/launch_controller.dart';
import '../../../global/launch/controller/launch_manager.dart';
import '../../../global/user/user.dart';
import '../../../global/user/user_bean.dart';

class SetupController extends GetxController {
  ///用户信息
  final UserController _userController = Get.find<UserController>();

  // 将 userInfo 转换为响应式数据
  final Rx<UserInfoBean?> _userInfo = Rx<UserInfoBean?>(null);
  UserInfoBean? get userInfo => _userInfo.value;

  List protocolList = [];
  final RxInt unreadMessageCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时获取用户信息
    _updateUserInfo();
    // 监听 UserController 中的 userInfoBean 变化
    ever(_userController.userInfoBean, _updateUserInfo);

    ///过滤显示的协议
    protocolList = GlobalController.instance.config.protocolList
        .where((e) => e.show)
        .toList();
    getUnreadMessageCount();
  }

  // 更新用户信息
  void _updateUserInfo([UserInfoBean? info]) {
    _userInfo.value = info ?? _userController.userInfoBean.value;
  }

  ///退出登录
  void logout() {
    HttpUtils.post(
      APIs.logout,
      {},
      success: (data) async {
        if (data["status"] == 200) {
          ///重新调用启动接口并更新用户信息-到登录页
          Get.find<LaunchController>().appLaunch(
            onSuccess: (LaunchInfoBean bean) {
              _userController.clearUserInfo();
              Get.find<ProfileController>().reloadData();
              _userController.reloadUserInfo(
                goBack: () {
                  Get.back();
                  LoginManager.login(source: 'profile_setup');
                },
              );
            },
          );
        }
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
      },
    );
  }

  ///注销账号
  void deleteAccount() {
    ///一键登录初始化预取号
    HttpUtils.post(
      APIs.accountCancellations,
      {},
      showLoading: true,
      success: (data) {
        // Toast.showText(text: "Close account success");

        ///重新调用启动接口并更新用户信息-到登录页
        Get.find<LaunchController>().appLaunch(
          onSuccess: (LaunchInfoBean bean) {
            _userController.clearUserInfo();
            _userController.reloadUserInfo(
              goBack: () {
                Get.back();
                LoginManager.login(source: 'profile_setup');
              },
            );
          },
        );
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
      },
    );
  }

  ///退出登录弹窗确认
  void showLogoutConfirm() {
    ByDialogUtil.showPopScopeDialog(
      context: Get.context!,
      title: 'Log out',
      contents: 'Are you sure to logout?',
      confirmCallback: () {
        logout();
      },
    );
  }

  ///注销账号弹窗确认
  void showDeleteAccountConfirm() {
    ByDialogUtil.showPopScopeDialog(
      context: Get.context!,
      title: 'Close Account',
      // contents: '1、账户一旦注销，该账户下的信息、数据、记录将全部删除，且无法恢复。\n2、注销后，账户下的全部权益均被清除:且无法恢复。\n3、注销后，该账户绑定的第三方账户将被解除绑定，您可重新使用并注册成为新用户。\n4、提交注销后将在三个工作日内完成数据清除',
      contents:
          "1. Once the account is closed, all information, data, and records under the account will be deleted and cannot be restored.\n2. After cancellation, all rights and interests under the account will be cleared and cannot be restored.\n3. After cancellation, the third-party accounts bound to the account will be unbound, and you can re-use and register as a new user.\n4. After submitting the cancellation, the data will be cleared within three working days.",
      confirmBtnTitle: 'Continue',
      confirmCallback: () {
        deleteAccount();
      },
    );
  }

  ///根据标题匹配跳转协议
  void getProtocolByTitle(String title) {
    GlobalController.instance.config.goPrivacyPageWithTitle(title);
  }

  void getUnreadMessageCount() {
    HttpUtils.get(
      APIs.messageUnreadCount,
      null,
      success: (data) {
        final dynamic count =
            data['data']?['unread_count'] ?? data['data']?['count'] ?? 0;
        unreadMessageCount.value =
            count is int ? count : int.tryParse('$count') ?? 0;
      },
      fail: (code, msg) {},
    );
  }
}

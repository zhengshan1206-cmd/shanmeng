import 'package:get/get.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/http_utils.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/global/routes/app_pages.dart';
import 'package:ling_bao/profile/message/bean/message_list_bean.dart';

class MessageController extends GetxController {
  static const int _pageSize = 10;

  final Rx<MultiStatusType> statusType = MultiStatusType.statusLoading.obs;
  final RxList<MessageListBean> messageList = <MessageListBean>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool hasMore = true.obs;

  final RefreshManager refreshManager = RefreshManager();

  @override
  void onInit() {
    super.onInit();
    getMessageList(true);
    getUnreadCount();
  }

  void getMessageList(bool isRefresh) {
    final manager = refreshManager;
    if (!manager.beginRequest(isRefresh, hasMore: hasMore.value)) {
      return;
    }

    if (isRefresh) {
      if (messageList.isEmpty) {
        statusType.value = MultiStatusType.statusLoading;
      }
      hasMore.value = true;
    }

    final int requestPage = manager.pageHelper.page;
    HttpUtils.get(
      APIs.messageList,
      {'page': requestPage, 'per_page': _pageSize},
      success: (data) {
        final dynamic resData = data['data'];
        final List list = resData is Map ? (resData['data'] ?? []) : [];
        final int lastPage = resData is Map
            ? (resData['last_page'] as int? ?? 1)
            : 1;
        final beans = list
            .map((e) => MessageListBean.fromJson(e as Map<String, dynamic>))
            .toList();
        if (isRefresh) {
          messageList.value = beans;
        } else {
          messageList.addAll(beans);
        }

        final bool nextHasMore = requestPage < lastPage;
        hasMore.value = nextHasMore;

        if (messageList.isEmpty) {
          statusType.value = MultiStatusType.statusEmpty;
        } else {
          statusType.value = MultiStatusType.statusContent;
        }
        manager.completeSuccess(isRefresh: isRefresh, hasMore: nextHasMore);
      },
      fail: (code, msg) {
        if (messageList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        manager.completeFailed(isRefresh);
        Toast.showText(text: msg);
      },
    );
  }

  void getUnreadCount() {
    HttpUtils.get(
      APIs.messageUnreadCount,
      null,
      success: (data) {
        final dynamic count =
            data['data']?['unread_count'] ?? data['data']?['count'] ?? 0;
        unreadCount.value = count is int ? count : int.tryParse('$count') ?? 0;
      },
      fail: (code, msg) {},
    );
  }

  void markMessageRead(MessageListBean bean) {
    HttpUtils.post(
      APIs.messageRead,
      {'message_id': bean.id},
      success: (data) {
        if (bean.isRead == 0) {
          bean.isRead = 1;
          messageList.refresh();
          if (unreadCount.value > 0) {
            unreadCount.value -= 1;
          }
        }
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
      },
    );
  }

  void jumpMessageDetails(MessageListBean bean) {
    if (bean.isRead == 0) {
      markMessageRead(bean);
    }
    Get.toNamed(Routes.messageDetails, arguments: bean);
  }

  @override
  void onClose() {
    refreshManager.dispose();
    super.onClose();
  }
}

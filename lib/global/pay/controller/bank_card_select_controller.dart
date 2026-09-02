import 'package:get/get.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/http_utils.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';
import 'package:ling_bao/global/pay/bean/bank_pay_bank_bean.dart';
import 'dart:async';

import '../../other/event_tracking/event_tracking.dart';

class BankCardSelectController extends GetxController {
  static const String defaultPayId = 'baofu';

  final RxList<BankPayBankBean> banks = <BankPayBankBean>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool loadFailed = false.obs;

  late final String payId;
  late final String orderNo;

  @override
  void onInit() {
    super.onInit();
    payId = _resolvePayId();
    orderNo = _resolveOrderNo();
    final List<BankPayBankBean> initialBanks = _resolveBanks();
    if (initialBanks.isNotEmpty) {
      banks.assignAll(initialBanks);
      isLoading.value = false;
      return;
    }
    fetchBanks();
  }

  List<BankPayBankBean> _resolveBanks() {
    final dynamic args = Get.arguments;
    if (args is List<BankPayBankBean> && args.isNotEmpty) {
      return List<BankPayBankBean>.from(args);
    }
    if (args is Map<String, dynamic>) {
      final dynamic bankList = args['banks'];
      if (bankList is List<BankPayBankBean> && bankList.isNotEmpty) {
        return List<BankPayBankBean>.from(bankList);
      }
      if (bankList is List && bankList.isNotEmpty) {
        final List<BankPayBankBean> results = bankList
            .whereType<BankPayBankBean>()
            .toList();
        if (results.isNotEmpty) {
          return results;
        }
      }
    }
    return <BankPayBankBean>[];
  }

  String _resolvePayId() {
    final dynamic args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final dynamic targetPayId = args['payId'] ?? args['pay_id'];
      if (targetPayId != null && targetPayId.toString().isNotEmpty) {
        return targetPayId.toString();
      }
    }
    return defaultPayId;
  }

  String _resolveOrderNo() {
    final dynamic args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final dynamic targetOrderNo =
          args['orderno'] ?? args['order_no'] ?? args['orderNo'];
      if (targetOrderNo != null && targetOrderNo.toString().isNotEmpty) {
        return targetOrderNo.toString();
      }
    }
    return '';
  }

  String _resolveCardBankCode(BankPayBankBean bank) {
    if (bank.vendorBankCodeText.isNotEmpty) {
      return bank.vendorBankCodeText;
    }
    if (bank.vendorBankCode.isNotEmpty) {
      return bank.vendorBankCode;
    }
    return bank.bankCode;
  }

  String _resolveCardType(BankCardType cardType) {
    return cardType == BankCardType.credit ? '102' : '101';
  }

  Future<void> fetchBanks() async {
    isLoading.value = true;
    loadFailed.value = false;
    await HttpUtils.get(
      APIs.bankList,
      {'pay_id': payId},
      showMsgWhenFailed: true,
      success: (data) {
        final dynamic banksData = data['data']?['banks'];
        final List items = banksData is List ? banksData : <dynamic>[];
        final List<BankPayBankBean> results =
            items
                .map(
                  (item) =>
                      BankPayBankBean.fromJson(item as Map<String, dynamic>),
                )
                .toList()
              ..sort((a, b) => a.sort.compareTo(b.sort));
        banks.assignAll(results);
        isLoading.value = false;
        loadFailed.value = false;
      },
      fail: (code, msg) {
        isLoading.value = false;
        loadFailed.value = true;
      },
    );
  }

  Future<String?> applySign({
    required BankPayBankBean bank,
    required String cardName,
    required String cardId,
    required BankCardType cardType,
  }) async {
    if (orderNo.isEmpty) {
      Toast.showText(text: '缺少订单号');
      return null;
    }

    final Completer<String?> completer = Completer<String?>();
    HttpUtils.post(
      APIs.applySign,
      {
        'card_name': cardName,
        'card_id': cardId,
        'card_bank': _resolveCardBankCode(bank),
        'card_type': _resolveCardType(cardType),
        'orderno': orderNo,
      },
      showLoading: true,
      loadingText: '签约申请中...',
      success: (data) {
        EventTracking.reportDataPoint(
          pageTag: 'user_info_suc',
          operateType: 'click',
          funcDetailTag: '',
          funcDetailImg: '',
        );
        final String url = data['data']['url']?.toString() ?? '';
        if (url.isEmpty) {
          Toast.showText(text: '签约链接获取失败');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          return;
        }
        if (!completer.isCompleted) {
          completer.complete(url);
        }
      },
      fail: (code, msg) {
        EventTracking.reportDataPoint(
          pageTag: 'user_info_fail',
          operateType: 'click',
          funcDetailTag: '',
          funcDetailImg: '',
        );
        Toast.showText(text: msg);
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );
    return completer.future;
  }
}

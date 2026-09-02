import 'package:get/get.dart';
import 'package:ling_bao/global/pay/controller/bank_card_select_controller.dart';

class BankCardSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BankCardSelectController>(() => BankCardSelectController());
  }
}

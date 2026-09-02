import 'package:get/get.dart';
import 'package:ling_bao/profile/order/controller/order_history_controller.dart';

class OrderHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
  }
}

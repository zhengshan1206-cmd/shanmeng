import 'package:get/get.dart';
import 'package:ling_bao/profile/order/controller/order_management_controller.dart';

class OrderManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderManagementController>(() => OrderManagementController());
  }
}

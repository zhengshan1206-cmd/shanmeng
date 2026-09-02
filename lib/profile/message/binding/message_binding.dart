import 'package:get/get.dart';
import 'package:ling_bao/profile/message/controller/message_controller.dart';

class MessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageController>(() => MessageController());
  }
}

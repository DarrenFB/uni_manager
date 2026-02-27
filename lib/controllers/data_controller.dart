import 'package:get/get.dart';
import 'package:uni_manager/controllers/app_controller.dart';
import 'package:uni_manager/controllers/data_controller.dart' as controller;

class DataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppController>(() => AppController(Get.find()));
  }
}
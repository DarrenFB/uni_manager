import 'package:get/get.dart';
import 'package:uni_manager/controllers/view_controller.dart';

class ViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewController>(() => ViewController());
  }
}
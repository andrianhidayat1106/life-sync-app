import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/project/controllers/project_controller.dart';

import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());

    Get.lazyPut<ProjectController>(() => ProjectController());
  }
}

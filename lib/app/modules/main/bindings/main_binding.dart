import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/category/controllers/category_controller.dart';
import 'package:lifesync_app/app/modules/project/controllers/project_controller.dart';
import 'package:lifesync_app/app/modules/task/controllers/task_controller.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/wallet_controller.dart';

import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());

    Get.lazyPut<ProjectController>(() => ProjectController());
    Get.lazyPut<WalletController>(() => WalletController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<TaskController>(() => TaskController());
  }
}

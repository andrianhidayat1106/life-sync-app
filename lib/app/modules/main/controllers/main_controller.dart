import 'package:get/get.dart';

class MainController extends GetxController {
  var selectedIndex = 2.obs; // Default ke 'Beranda'

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

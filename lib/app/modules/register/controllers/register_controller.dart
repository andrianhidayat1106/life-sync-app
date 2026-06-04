import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/user_model.dart';
import 'package:lifesync_app/app/data/providers/register_provider.dart';
import 'package:lifesync_app/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final RegisterProvider _registerProvider = RegisterProvider();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> register() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = UserModel(fullName: fullName, email: email, password: password);
      await _registerProvider.register(user);

      Get.snackbar(
        'Sukses',
        'Registrasi berhasil. Silakan login.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Redirect ke halaman login setelah registrasi sukses
      Get.offNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Registrasi Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

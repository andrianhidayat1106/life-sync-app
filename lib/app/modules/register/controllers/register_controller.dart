import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/user_model.dart';
import 'package:lifesync_app/app/data/providers/register_provider.dart';
import 'package:lifesync_app/app/routes/app_pages.dart';
import 'package:lifesync_app/core/utils/ui_helper.dart';

class RegisterController extends GetxController {
  final RegisterProvider _registerProvider = RegisterProvider();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;

  Future<void> register() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      UIHelper.showErrorSnackbar('Semua field harus diisi');
      return;
    }

    try {
      isLoading.value = true;
      final user = UserModel(fullName: fullName, email: email, password: password);
      await _registerProvider.register(user);

      UIHelper.showSuccessSnackbar('Registrasi berhasil. Silakan login.');

      // Redirect ke halaman login setelah registrasi sukses
      Get.offNamed(Routes.LOGIN);
    } catch (e) {
      UIHelper.showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/user_model.dart';
import 'package:lifesync_app/app/data/providers/login_provider.dart';
import 'package:lifesync_app/app/routes/app_pages.dart';
import 'package:lifesync_app/core/services/cache_service.dart';
import 'package:lifesync_app/core/utils/ui_helper.dart';

class LoginController extends GetxController {
  final LoginProvider _loginProvider = LoginProvider();
  final CacheService _cacheServices = Get.find<CacheService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      UIHelper.showErrorSnackbar('Email dan password tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;
      final user = UserModel(email: email, password: password);
      final loggedInUser = await _loginProvider.login(user);

      // Simpan data user ke cache
      await _cacheServices.write('user_id', loggedInUser.id);
      await _cacheServices.write('user_email', loggedInUser.email);
      if (loggedInUser.fullName != null) {
        await _cacheServices.write('user_fullname', loggedInUser.fullName);
      }

      Get.offAllNamed(Routes.MAIN);
    } catch (e) {
      UIHelper.showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

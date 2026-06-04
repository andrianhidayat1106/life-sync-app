import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/app/routes/app_pages.dart';
import 'package:lifesync_app/core/services/cache_service.dart';

class ProfileController extends GetxController {
  final CacheService _cacheService = Get.find<CacheService>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final fullName = ''.obs;
  final email = ''.obs;
  final profileImagePath = ''.obs;
  final isLoading = false.obs;
  final isUpdatingPassword = false.obs;

  // Visibility toggles
  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // Strength criteria
  final isPasswordLengthMet = false.obs;
  final isPasswordComplexityMet = false.obs;
  final isPasswordNotCommon = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    setupPasswordListeners();
  }

  void setupPasswordListeners() {
    newPasswordController.addListener(() {
      final text = newPasswordController.text;
      isPasswordLengthMet.value = text.length >= 8;

      final hasNumber = RegExp(r'[0-9]').hasMatch(text);
      final hasSymbol = RegExp(r'[!@#\$&*~_+-]').hasMatch(text);
      isPasswordComplexityMet.value = hasNumber && hasSymbol;

      final lower = text.toLowerCase();
      final isCommon = lower.contains('password') || 
                       lower.contains('123456') || 
                       lower.contains('qwerty') || 
                       lower.contains('admin');
      isPasswordNotCommon.value = text.isNotEmpty && !isCommon;
    });
  }

  void loadUserData() {
    final cachedName = _cacheService.read<String>('user_fullname') ?? '';
    final cachedEmail = _cacheService.read<String>('user_email') ?? '';
    final cachedImage = _cacheService.read<String>('user_profile_picture') ?? '';

    profileImagePath.value = cachedImage;
    fullName.value = cachedName;
    email.value = cachedEmail;

    fullNameController.text = cachedName;
    emailController.text = cachedEmail;
  }

  Future<void> pickAndSaveImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Simpan file ke storage lokal aplikasi agar persisten
        final directory = await getApplicationDocumentsDirectory();
        final String path = directory.path;
        final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
        final File localFile = await File(image.path).copy('$path/$fileName');

        // Tulis path baru ke CacheService
        await _cacheService.write('user_profile_picture', localFile.path);
        profileImagePath.value = localFile.path;

        Get.snackbar(
          'Sukses',
          'Foto profil berhasil diperbarui secara lokal',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Memilih Foto',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      await _cacheService.remove('user_profile_picture');
      profileImagePath.value = '';
      Get.snackbar(
        'Sukses',
        'Foto profil berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Menghapus Foto',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveChanges() async {
    final newName = fullNameController.text.trim();
    final newEmail = emailController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama dan Email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Simpan perubahan ke local CacheService
      await _cacheService.write('user_fullname', newName);
      await _cacheService.write('user_email', newEmail);

      fullName.value = newName;
      email.value = newEmail;

      // Sinkronisasi dengan Supabase Auth metadata jika memungkinkan
      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      if (currentUser != null) {
        await client.auth.updateUser(
          UserAttributes(
            email: newEmail != currentUser.email ? newEmail : null,
            data: {'full_name': newName},
          ),
        );
      }

      Get.snackbar(
        'Sukses',
        'Profil berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Menyimpan',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      // Sign out dari Supabase dengan toleransi error jika sesi sudah tidak valid
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        print("[ProfileController] Supabase signOut error (ignoring): $e");
      }
      
      // Hapus data lokal dari CacheService
      await _cacheService.clear();

      Get.snackbar(
        'Logout',
        'Anda telah keluar dari aplikasi',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Kembalikan ke halaman login
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal melakukan logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua kolom kata sandi harus diisi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword.length < 8) {
      Get.snackbar(
        'Error',
        'Kata sandi baru minimal harus 8 karakter',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Konfirmasi kata sandi baru tidak cocok',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isUpdatingPassword.value = true;

      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception("User tidak ditemukan atau belum login");
      }

      // Verifikasi password saat ini dengan mencoba re-autentikasi
      await client.auth.signInWithPassword(
        email: currentUser.email!,
        password: currentPassword,
      );

      // Jika re-autentikasi berhasil, lakukan update password
      await client.auth.updateUser(UserAttributes(password: newPassword));

      Get.snackbar(
        'Sukses',
        'Kata sandi berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Kosongkan kolom input
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      Get.snackbar(
        'Gagal Memperbarui Sandi',
        e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdatingPassword.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

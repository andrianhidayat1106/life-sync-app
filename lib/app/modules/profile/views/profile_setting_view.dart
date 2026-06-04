import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/profile/controllers/profile_controller.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileSettingView extends GetView<ProfileController> {
  const ProfileSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan data terbaru dimuat ketika halaman dibuka
    controller.loadUserData();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Photo Profile Section
              _buildPhotoSection(),
              const SizedBox(height: 32),

              // 2. Personal Information Card
              _buildSectionTitle('Informasi Pribadi'),
              const SizedBox(height: 12),
              _buildFormCard([
                _buildTextField(
                  label: 'Nama Lengkap',
                  controller: controller.fullNameController,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Alamat Email',
                  controller: controller.emailController,
                ),
                const SizedBox(height: 32),
                Obx(
                  () => _buildActionButton(
                    label: controller.isLoading.value
                        ? 'Menyimpan...'
                        : 'Simpan Perubahan',
                    onPressed: controller.isLoading.value
                        ? () {}
                        : () => controller.saveChanges(),
                    backgroundColor: Colors.black,
                  ),
                ),
              ]),

              const SizedBox(height: 32),

              // 3. Security & Password Card
              _buildSectionTitle('Keamanan & Kata Sandi'),
              const SizedBox(height: 12),
              _buildFormCard([
                Obx(
                  () => _buildTextField(
                    label: 'Kata Sandi Saat Ini',
                    obscureText: controller.obscureCurrentPassword.value,
                    controller: controller.currentPasswordController,
                    hintText: '********',
                    suffix: IconButton(
                      icon: Icon(
                        controller.obscureCurrentPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => controller.obscureCurrentPassword.toggle(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => _buildTextField(
                    label: 'Kata Sandi Baru',
                    obscureText: controller.obscureNewPassword.value,
                    controller: controller.newPasswordController,
                    hintText: 'Masukkan kata sandi baru',
                    suffix: IconButton(
                      icon: Icon(
                        controller.obscureNewPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => controller.obscureNewPassword.toggle(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => _buildTextField(
                    label: 'Konfirmasi Kata Sandi',
                    obscureText: controller.obscureConfirmPassword.value,
                    controller: controller.confirmPasswordController,
                    hintText: 'Ulangi kata sandi baru',
                    suffix: IconButton(
                      icon: Icon(
                        controller.obscureConfirmPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => controller.obscureConfirmPassword.toggle(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Security Criteria
                _buildSecurityCriteria(),
                const SizedBox(height: 32),
                Obx(
                  () => _buildActionButton(
                    label: controller.isUpdatingPassword.value
                        ? 'Memperbarui...'
                        : 'Perbarui Kata Sandi',
                    onPressed: controller.isUpdatingPassword.value
                        ? () {}
                        : () => controller.changePassword(),
                    isOutlined: true,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEFF4FF), width: 3),
              ),
              child: Obx(() {
                final path = controller.profileImagePath.value;
                if (path.isNotEmpty && File(path).existsSync()) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(File(path)),
                  );
                } else {
                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: SvgPicture.asset(
                        'assets/images/user.svg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => controller.pickAndSaveImage(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF065F46),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ganti Foto',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => controller.deleteProfileImage(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.outline),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    String? hintText,
    bool obscureText = false,
    Widget? suffix,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffix ?? (suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.textSecondary)
                : null),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Colors.black, width: 1.5),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCriteria() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kriteria Keamanan:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => _buildCriteriaItem(
                'Minimal 8 karakter',
                controller.isPasswordLengthMet.value,
              )),
          const SizedBox(height: 8),
          Obx(() => _buildCriteriaItem(
                'Kombinasi angka & simbol',
                controller.isPasswordComplexityMet.value,
              )),
          const SizedBox(height: 8),
          Obx(() => _buildCriteriaItem(
                'Hindari kata-kata umum',
                controller.isPasswordNotCommon.value,
              )),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String label, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.info_outline,
          size: 18,
          color: isMet ? const Color(0xFF065F46) : AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isMet ? const Color(0xFF065F46) : AppColors.textSecondary,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

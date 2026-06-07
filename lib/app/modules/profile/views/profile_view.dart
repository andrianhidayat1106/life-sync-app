import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:lifesync_app/app/routes/app_pages.dart';
import 'package:lifesync_app/core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "Profil"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Profile Header Section
              _buildProfileHeader(context),
              const SizedBox(height: 32),

              // 2. Account Settings Group
              _buildSectionTitle('PENGATURAN AKUN'),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingsItem(
                  icon: Icons.person_outline,
                  title: 'Informasi Pribadi',
                  onTap: () => Get.toNamed(Routes.PROFILE + '/setting'),
                ),

                Obx(() => _buildSettingsItem(
                  icon: Icons.notifications_none,
                  title: 'Preferensi Notifikasi',
                  badge: controller.unreadNotificationCount.value > 0 
                      ? controller.unreadNotificationCount.value.toString() 
                      : null,
                  onTap: () {
                    Get.toNamed(Routes.NOTIFICATION)?.then((_) {
                      controller.fetchUnreadNotificationCount();
                    });
                  },
                )),
              ]),

              const SizedBox(height: 32),

              // 3. Tombol Logout Premium (Keluar dari Aplikasi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                    label: const Text(
                      'Keluar dari Aplikasi',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(
                        color: Color(0xFFFCA5A5),
                        width: 1.5,
                      ),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Header Profil menampilkan data dari controller secara reaktif
  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.2),
                  width: 3,
                ),
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

        Obx(
          () => Text(
            controller.fullName.value.isNotEmpty
                ? controller.fullName.value
                : 'Nama Pengguna',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ),

        Obx(
          () => Text(
            controller.email.value.isNotEmpty
                ? controller.email.value
                : 'user@email.com',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: OutlinedButton.icon(
            onPressed: () => controller.pickAndSaveImage(),
            icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
            label: const Text(
              'Edit Profil',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              side: const BorderSide(color: AppColors.outline),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary.withOpacity(0.8),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? badge,
    String? status,
    Color? statusColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != null)
            Text(
              status,
              style: TextStyle(
                color: statusColor ?? AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Keluar Akun',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi LifeSync? Sesi Anda akan dihentikan dan harus masuk kembali nanti.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout();
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

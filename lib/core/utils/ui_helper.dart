import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_calendar_dialog.dart';

class UIHelper {
  // 1. SNACKBARS
  static void showSuccessSnackbar(String message) {
    _showCustomSnackbar(
      message: message,
      icon: Icons.check_circle,
      iconColor: const Color(0xFF10B981), // Emerald/Green
    );
  }

  static void showErrorSnackbar(String message) {
    _showCustomSnackbar(
      message: message,
      icon: Icons.error_rounded,
      iconColor: const Color(0xFFEF4444), // Rose/Red
    );
  }

  static void _showCustomSnackbar({
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xF00F172A), // Slate-900 (Dynamic Island dark style)
      borderRadius: 24,
      margin: const EdgeInsets.only(top: 20),
      maxWidth: 300, // Compact width resembling Dynamic Island
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  // 2. DELETE CONFIRMATION DIALOG (NOTIFICATION MODAL STYLE)
  static void showDeleteConfirmDialog({
    required String title,
    required String description,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2), // Light red
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFB00020), // Dark red
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Dismiss dialog
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB00020), // Dark red
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. CUSTOM CALENDAR DATE PICKER DIALOG
  static Future<DateTime?> showCustomDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return Get.dialog<DateTime>(
      CustomCalendarDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }
}

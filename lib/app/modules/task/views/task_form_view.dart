import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/task_controller.dart';

class TaskFormView extends GetView<TaskController> {
  const TaskFormView({super.key});

  Color _parseColor(String hex) {
    if (hex.startsWith('#')) {
      final cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } else if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF6B7280);
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'work':
      case 'work_outline':
        return Icons.work_outline;
      case 'person':
      case 'person_outline':
        return Icons.person_outline;
      case 'payments':
      case 'payments_outlined':
        return Icons.payments_outlined;
      case 'medical_services':
      case 'medical_services_outlined':
        return Icons.medical_services_outlined;
      case 'account_balance':
        return Icons.account_balance;
      case 'airplanemode_active':
        return Icons.airplanemode_active;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'home':
        return Icons.home;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'school':
        return Icons.school;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime dt) {
    final List<String> monthsShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = monthsShort[dt.month - 1];
    final year = dt.year;
    
    final List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final dayName = days[dt.weekday - 1];
    
    return '$dayName, $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Obx(() => Text(
              controller.isEditMode.value ? 'Edit Tugas' : 'Tambah Tugas',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            )),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.isEditMode.value) {
              return IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Hapus Tugas',
                    middleText: 'Apakah Anda yakin ingin menghapus tugas ini?',
                    textConfirm: 'Hapus',
                    textCancel: 'Batal',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () {
                      Get.back(); // Tutup dialog
                      controller.deleteTaskFromForm();
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outline.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Judul Tugas'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.titleController,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Apa yang ingin dikerjakan?',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.outline, thickness: 0.5),
                    const SizedBox(height: 20),
                    _buildLabel('Deskripsi Detail'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan catatan atau detail tugas di sini...',
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Category Selection
              _buildLabel('KATEGORI'),
              const SizedBox(height: 12),
              Obx(() {
                final list = controller.categories;
                final selectedCategoryId = controller.selectedFormCategoryId.value;
                if (list.isEmpty) {
                  return const Text(
                    'Tidak ada kategori produktivitas. Silakan buat dahulu.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  );
                }
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: list.map((cat) {
                    final isSelected = selectedCategoryId == cat.id;
                    final catColor = _parseColor(cat.colorHex);
                    return GestureDetector(
                      onTap: () => controller.selectedFormCategoryId.value = cat.id ?? '',
                      child: _buildTag(
                        cat.name,
                        _getIconData(cat.icon),
                        isSelected,
                        catColor,
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 32),

              // Priority Selection
              _buildLabel('PRIORITAS'),
              const SizedBox(height: 12),
              Obx(() {
                final selectedPriority = controller.selectedPriority.value;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectedPriority.value = 'low',
                          child: _buildPriorityOption('Rendah', selectedPriority == 'low'),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectedPriority.value = 'medium',
                          child: _buildPriorityOption('Sedang', selectedPriority == 'medium'),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectedPriority.value = 'high',
                          child: _buildPriorityOption('Tinggi', selectedPriority == 'high'),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),

              // Deadline Section
              _buildLabel('TENGGAT WAKTU'),
              const SizedBox(height: 12),
              Obx(() {
                final date = controller.selectedFormDueDate.value;
                final dateText = date != null ? _formatDate(date) : 'Pilih Tenggat Tanggal';

                return GestureDetector(
                  onTap: () => controller.selectFormDate(context),
                  child: _buildDateTimePickerField(
                    Icons.calendar_today_outlined,
                    dateText,
                  ),
                );
              }),
              const SizedBox(height: 48),

              // Save Button
              Obx(() {
                final isLoading = controller.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => controller.saveTask(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isLoading
                          ? 'Menyimpan...'
                          : (controller.isEditMode.value ? 'Simpan Perubahan' : 'Simpan Tugas'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTag(String label, IconData icon, bool isSelected, Color catColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? catColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? catColor : AppColors.outline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePickerField(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
               text,
               style: const TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: AppColors.textPrimary,
               ),
               maxLines: 1,
               overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

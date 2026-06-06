import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/project/controllers/project_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helper.dart';

class ProjectFormView extends GetView<ProjectController> {
  const ProjectFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Obx(() => Text(
          controller.isEditMode.value ? 'Edit Proyek' : 'Proyek Baru',
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
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Hapus Proyek'),
                      content: const Text(
                        'Apakah Anda yakin ingin menghapus proyek ini? Semua tugas di dalamnya juga akan terhapus secara permanen.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.deleteProjectFromForm();
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                controller.isEditMode.value ? 'Ubah Proyek' : 'Buat Proyek Baru',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              )),
              const SizedBox(height: 8),
              const Text(
                'Rencanakan langkah besar Anda berikutnya dengan detail yang terstruktur.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Form Utama
              _buildLabel('Nama Proyek'),
              const SizedBox(height: 8),
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Renovasi Kantor Pusat',
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Deskripsi'),
              const SizedBox(height: 8),
              TextField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan tujuan utama dan lingkup proyek ini...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Kategori
              _buildLabel('Kategori'),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.categories.isEmpty) {
                  return const Text(
                    'Tidak ada kategori general tersedia.',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.categories.map((cat) {
                    final isSelected =
                        controller.selectedFormCategoryId.value == cat.id;
                    return GestureDetector(
                      onTap: () {
                        controller.selectedFormCategoryId.value = cat.id ?? '';
                      },
                      child: _buildTag(
                        cat.name,
                        _getIconData(cat.icon),
                        isSelected,
                        _parseColor(cat.colorHex),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 32),

              // Prioritas
              _buildLabel('Prioritas'),
              const SizedBox(height: 12),
              Obx(() => Container(
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
                        child: _buildPriorityOption(
                          'Rendah',
                          controller.selectedPriority.value == 'low',
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            controller.selectedPriority.value = 'medium',
                        child: _buildPriorityOption(
                          'Sedang',
                          controller.selectedPriority.value == 'medium',
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedPriority.value = 'high',
                        child: _buildPriorityOption(
                          'Tinggi',
                          controller.selectedPriority.value == 'high',
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 32),

              // Tenggat Waktu
              _buildLabel('Tenggat Waktu'),
              const SizedBox(height: 12),
              Obx(() {
                final date = controller.selectedFormDeadline.value;
                final dateText = date != null
                    ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
                    : "";
                return TextField(
                  readOnly: true,
                  controller: TextEditingController(text: dateText),
                  onTap: () async {
                    final picked = await UIHelper.showCustomDatePicker(
                      initialDate: date ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      controller.selectedFormDeadline.value = picked;
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'dd/mm/yyyy',
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // SEKSI TUGAS AWAL
              Obx(() => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tambah Tugas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OPSIONAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (controller.formSubTasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'Belum ada tugas tambahan. Klik tombol di bawah untuk menambah.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.formSubTasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final subtask = controller.formSubTasks[index];
                          return _buildInitialTaskField(
                            index: index,
                            subtask: subtask,
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    // Tombol Tambah Baris Baru
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.addSubTaskField();
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppColors.success,
                        ),
                        label: const Text(
                          'Tambah Tugas Baru',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: AppColors.success.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 48),

              // Tombol Aksi Akhir
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.saveProject(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          controller.isEditMode.value
                              ? 'Simpan Perubahan'
                              : 'Simpan Proyek',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),

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
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null) return const Color(0xFF6B7280);
    String hex = colorHex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
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

  Widget _buildTag(String label, IconData icon, bool isSelected, Color catColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? catColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? catColor : AppColors.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? catColor : AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? catColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.05),
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

  Widget _buildInitialTaskField({
    required int index,
    required ProjectSubTask subtask,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
          ),
          child: SizedBox(
            height: 24,
            width: 24,
            child: Obx(() => Checkbox(
              value: subtask.isCompleted.value,
              onChanged: (bool? value) {
                if (value != null) {
                  subtask.isCompleted.value = value;
                }
              },
              activeColor: AppColors.success,
              checkColor: Colors.white,
              side: const BorderSide(
                color: AppColors.outline,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: subtask.controller,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Langkah berikutnya...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Container(
                height: 48,
                alignment: Alignment.center,
                width: 40,
                child: IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(right: 4.0),
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    size: 20,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    controller.removeSubTaskField(index);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

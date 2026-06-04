import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/category/controllers/category_controller.dart';
import 'package:lifesync_app/app/modules/category/components/segment_tab_widget.dart';
import '../../../../core/constants/app_colors.dart';

class CategoryFormView extends GetView<CategoryController> {
  const CategoryFormView({super.key});

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'airplanemode_active':
        return Icons.airplanemode_active;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'payments':
        return Icons.payments;
      case 'restaurant':
        return Icons.restaurant;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'school':
        return Icons.school;
      case 'more_horiz':
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      'account_balance',
      'airplanemode_active',
      'shopping_cart',
      'home',
      'work',
      'payments',
      'restaurant',
      'fitness_center',
      'school',
      'more_horiz',
    ];

    final colors = [
      '065F46', // Emerald
      '1E293B', // Slate
      '10B981', // Light Emerald
      '3B82F6', // Blue
      'EF4444', // Red
      'F59E0B', // Amber
      '8B5CF6', // Violet
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Obx(() => Text(
              controller.isEditMode.value ? 'Edit Kategori' : 'Tambah Kategori',
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
                    title: 'Hapus Kategori',
                    middleText: 'Apakah Anda yakin ingin menghapus kategori ini?',
                    textConfirm: 'Hapus',
                    textCancel: 'Batal',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () {
                      Get.back(); // Tutup dialog
                      controller.deleteCategory(controller.editCategoryId.value);
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
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pratinjau Visual (Reactive)
              _buildLabel('PRATINJAU VISUAL'),
              const SizedBox(height: 16),
              _buildCategoryPreview(),
              const SizedBox(height: 32),

              // 2. Tipe Kategori (Toggle Segmented Tab)
              _buildLabel('Tipe Kategori'),
              const SizedBox(height: 12),
              SegmentedTabWidget(
                selectedIndex: controller.selectedTypeIndex,
                onTabChanged: (val) {
                  controller.selectedType.value = val == 0 ? 'finance' : 'general';
                },
              ),
              const SizedBox(height: 32),

              // 3. Nama Kategori
              _buildLabel('Nama Kategori'),
              const SizedBox(height: 12),
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  hintText: 'Misal: Perjalanan Bisnis',
                ),
              ),
              const SizedBox(height: 32),

              // 4. Pilih Ikon (Reactive)
              _buildLabel('Pilih Ikon'),
              const SizedBox(height: 16),
              _buildIconGrid(icons),
              const SizedBox(height: 32),

              // 5. Warna Identitas (Reactive)
              _buildLabel('Warna Identitas'),
              const SizedBox(height: 16),
              _buildColorSelector(colors),
              const SizedBox(height: 32),

              // 6. Deskripsi
              _buildLabel('Deskripsi (Opsional)'),
              const SizedBox(height: 12),
              TextField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan penggunaan kategori ini...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 48),

              // 7. Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.saveCategory(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        controller.isLoading.value
                            ? 'Menyimpan...'
                            : (controller.isEditMode.value ? 'Simpan Perubahan' : 'Simpan Kategori'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildCategoryPreview() {
    return Obx(() {
      final name = controller.previewName.value;
      final typeText = controller.selectedType.value == 'finance' ? 'Finance' : 'Productivity';
      final colorHex = controller.selectedColorHex.value;
      final color = Color(int.parse('FF$colorHex', radix: 16));
      final icon = _getIconData(controller.selectedIcon.value);

      return Container(
        width: double.infinity,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tipe: $typeText',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildIconGrid(List<String> icons) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: icons.map((iconName) {
            final icon = _getIconData(iconName);
            return Obx(() {
              final isSelected = controller.selectedIcon.value == iconName;
              return GestureDetector(
                onTap: () => controller.selectedIcon.value = iconName,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary.withOpacity(0.15)
                        : AppColors.surfaceContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.secondary, width: 1.5)
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColorSelector(List<String> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: colors.map((hex) {
          final color = Color(int.parse('FF$hex', radix: 16));
          return Obx(() {
            final isSelected = controller.selectedColorHex.value == hex;
            return GestureDetector(
              onTap: () => controller.selectedColorHex.value = hex,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: color, width: 2) : null,
                ),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}

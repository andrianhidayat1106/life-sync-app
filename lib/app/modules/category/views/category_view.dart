import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/category/controllers/category_controller.dart';
import 'package:lifesync_app/app/modules/category/components/segment_tab_widget.dart';
import 'package:lifesync_app/core/widgets/header.dart';
import '../../../../core/constants/app_colors.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({super.key});

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF065F46);
    final hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF065F46);
  }

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header / TopBar
              Obx(() => Header(
                title: controller.getUserFullName(),
                profileImagePath: controller.getUserAvatarUrl(),
              )),
              const SizedBox(height: 24),

              // Title Section
              const Text(
                'Category Manager',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Organize your financial flows and productivity workspaces.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Segmented Tab (Finance / Productivity)
              SegmentedTabWidget(
                selectedIndex: controller.selectedTab,
                onTabChanged: (value) => controller.selectedTab.value = value,
              ),
              const SizedBox(height: 32),

              // Kategori List (Reactive)
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                final isFinance = controller.selectedTab.value == 0;
                final filtered = controller.categories.where((cat) {
                  if (isFinance) {
                    return cat.type == 'finance';
                  } else {
                    return cat.type != 'finance';
                  }
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        'Tidak ada kategori ditemukan',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  );
                }

                return Column(
                  children: filtered.map((cat) {
                    final color = _parseColor(cat.colorHex);
                    return GestureDetector(
                      onTap: () {
                        controller.prepareEditForm(cat);
                        Get.toNamed('/category/create');
                      },
                      child: _buildIncomeItem(
                        cat.name,
                        cat.description ?? 'Kategori ${cat.type}',
                        color,
                        _getIconData(cat.icon),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.prepareCreateForm();
          Get.toNamed('/category/create');
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildIncomeItem(
    String title,
    String subtitle,
    Color iconBg,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

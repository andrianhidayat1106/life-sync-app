import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/category/views/category_view.dart';
import 'package:lifesync_app/app/modules/home/views/home_view.dart';
import 'package:lifesync_app/app/modules/main/controllers/main_controller.dart';
import 'package:lifesync_app/app/modules/project/views/project_view.dart';
import 'package:lifesync_app/app/modules/task/views/task_view.dart';
import 'package:lifesync_app/app/modules/wallet/views/wallet_view.dart';
import '../../../../core/constants/app_colors.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller jika belum ada

    // Daftar halaman (Placeholder)
    final List<Widget> _pages = [
      const CategoryView(),
      const WalletView(),
      const HomeView(),
      const TaskView(),
      const ProjectView(),
    ];

    return Scaffold(
      body: Obx(() => _pages[controller.selectedIndex.value]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Obx(
            () => BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.secondary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category),
                  label: 'Kategori',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Dompet',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment),
                  label: 'Proyek',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task),
                  activeIcon: Icon(Icons.task),
                  label: 'Task',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

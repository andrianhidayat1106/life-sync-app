import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/task/controllers/task_controller.dart';
import 'package:lifesync_app/app/modules/main/controllers/main_controller.dart';
import 'package:lifesync_app/app/modules/category/controllers/category_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/header.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF6B7280);
    final hex = hexString.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return const Color(0xFF6B7280);
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'account_balance': return Icons.account_balance;
      case 'airplanemode_active': return Icons.airplanemode_active;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      case 'payments': return Icons.payments;
      case 'restaurant': return Icons.restaurant;
      case 'fitness_center': return Icons.fitness_center;
      case 'school': return Icons.school;
      case 'account_balance_wallet':
      case 'wallet': return Icons.account_balance_wallet_outlined;
      case 'trending_up':
      case 'salary': return Icons.trending_up;
      case 'restaurant_outlined':
      case 'food': return Icons.restaurant_outlined;
      case 'shopping_bag':
      case 'shopping_bag_outlined':
      case 'shopping': return Icons.shopping_bag_outlined;
      case 'directions_car':
      case 'directions_car_outlined':
      case 'transport': return Icons.directions_car_outlined;
      case 'medical_services':
      case 'medical_services_outlined':
      case 'health': return Icons.medical_services_outlined;
      case 'bolt':
      case 'bills': return Icons.bolt;
      default: return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => controller.refreshHomeData(),
          color: const Color(0xFF065F46),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      Obx(
                        () => Header(
                          title: controller.getUserFullName(),
                          profileImagePath: controller.getUserAvatarUrl(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Consolidated Balance Card
                      _buildBalanceCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    children: [
                      _buildSectionHeader(
                        'Proyek Aktif',
                        'Lihat Semua',
                        () => Get.find<MainController>().changeIndex(4),
                        rightPadding: 24.0,
                      ),
                      const SizedBox(height: 16),
                      _buildProjectCarousel(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      // Today's Tasks Section
                      _buildSectionHeader('Tugas Hari Ini', 'Kelola Tugas', () {
                        final tc = Get.find<TaskController>();
                        tc.selectDate(DateTime.now());
                        Get.find<MainController>().changeIndex(3);
                      }),
                      const SizedBox(height: 16),
                      _buildTaskList(),
                      const SizedBox(height: 32),

                      // Recent Activity Section (Renamed to Transaksi Terakhir)
                      _buildSectionHeader(
                        'Transaksi Terakhir',
                        'Lihat Semua',
                        () => Get.toNamed('/wallet/transaction'),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentActivityList(),
                      const SizedBox(height: 100), // Padding for bottom nav
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Obx(() {
      final total = controller.totalBalance;
      final income = controller.totalIncome;
      final outcome = controller.totalOutcome;
      final chartHeights = controller.last7DaysActivity;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Saldo Terkonsolidasi',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${_formatCurrency(total)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceSummaryItem(
                    'PENDAPATAN',
                    'Rp ${_formatCurrency(income)}',
                    const Color(0xFFE0F7F1),
                    const Color(0xFF10B981),
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBalanceSummaryItem(
                    'PENGELUARAN',
                    'Rp ${_formatCurrency(outcome)}',
                    const Color(0xFFFEE2E2),
                    const Color(0xFFEF4444),
                    Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Chart Header
            const Text(
              'Aktivitas Transaksi 7 Hari Terakhir',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Chart Visual Bars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final height = chartHeights[index];
                final label = controller.last7DaysLabels[index];
                final isLast = index == 6;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChartBar(
                      height,
                      isLast
                          ? const Color(0xFF065F46)
                          : const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isLast
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isLast
                            ? const Color(0xFF065F46)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  income >= outcome ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: income >= outcome
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  income >= outcome ? 'Keuangan Surplus' : 'Keuangan Defisit',
                  style: TextStyle(
                    fontSize: 14,
                    color: income >= outcome
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  Widget _buildBalanceSummaryItem(
    String label,
    String value,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: textColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double height, Color color) {
    return Container(
      width: 28,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionLabel,
    VoidCallback onTap, {
    double rightPadding = 0.0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: rightPadding),
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCarousel() {
    return Obx(() {
      final list = controller.activeProjects;
      if (list.isEmpty) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open_outlined, color: AppColors.textSecondary.withValues(alpha: 0.4), size: 32),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum Ada Proyek Aktif',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mulai dengan membuat proyek baru untuk melacak kemajuan Anda.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final project = list[index];
            final progress = controller.projectController.getProgressPercentage(
              project.id?.toString() ?? '',
            );

            IconData getIcon() {
              switch (project.priority.toLowerCase()) {
                case 'high':
                  return Icons.priority_high;
                case 'low':
                  return Icons.arrow_downward;
                default:
                  return Icons.trending_up;
              }
            }

            return GestureDetector(
              onTap: () => Get.find<MainController>().changeIndex(4),
              child: _buildProjectCard(project.name, progress, getIcon()),
            );
          },
        ),
      );
    });
  }

  Widget _buildProjectCard(String title, double progress, IconData icon) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF10B981), size: 20),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.outline.withOpacity(0.3),
              color: const Color(0xFF10B981),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Obx(() {
      final list = controller.todayTasks;
      if (list.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(Icons.assignment_turned_in_outlined, color: const Color(0xFF10B981).withValues(alpha: 0.6), size: 36),
              const SizedBox(height: 12),
              const Text(
                'Tidak Ada Tugas Hari Ini',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Semua tugas Anda telah selesai! Nikmati hari Anda yang produktif.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }

      // Prioritaskan tugas yang belum selesai, lalu yang sudah selesai
      final incomplete = list.where((t) => !t.isCompleted).toList();
      final completed  = list.where((t) => t.isCompleted).toList();

      // Tampilkan max 5: incomplete dulu, sisa diisi completed
      const maxShow = 5;
      final displayList = [
        ...incomplete.take(maxShow),
        ...completed.take((maxShow - incomplete.length).clamp(0, maxShow)),
      ].take(maxShow).toList();

      final hiddenCount = list.length - displayList.length;

      return Column(
        children: [
          ...displayList.map((task) {
            final cat = controller.taskController.categories.firstWhereOrNull(
              (c) => c.id == task.categoryId,
            );
            final catName = cat?.name ?? 'Umum';
            final priorityStr = task.priority == 'high'
                ? 'Tinggi'
                : (task.priority == 'low' ? 'Rendah' : 'Sedang');
            final subtitle = '$catName • Prioritas: $priorityStr';

            return _buildTaskItem(
              task.title,
              subtitle,
              task.isCompleted,
              onToggle: () => controller.taskController.toggleTaskCompletion(
                task,
                customDate: DateTime.now(),
              ),
              onEdit: () {
                controller.taskController.prepareEditForm(task);
                Get.toNamed('/task/create');
              },
            );
          }),

          // Footer jika masih ada tugas tersembunyi
          if (hiddenCount > 0)
            GestureDetector(
              onTap: () {
                final tc = Get.find<TaskController>();
                tc.selectDate(DateTime.now());
                Get.find<MainController>().changeIndex(3);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.expand_more, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      '+ $hiddenCount tugas lainnya',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }


  Widget _buildTaskItem(
    String title,
    String subtitle,
    bool isCompleted, {
    required VoidCallback onToggle,
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : AppColors.textSecondary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
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
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Obx(() {
      final list = controller.todayTransactions;
      if (list.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary.withValues(alpha: 0.4), size: 36),
              const SizedBox(height: 12),
              const Text(
                'Belum Ada Transaksi Hari Ini',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Catat transaksi pengeluaran atau pemasukan Anda hari ini untuk memantau saldo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline.withOpacity(0.5)),
        ),
        child: Column(
          children: List.generate(list.length * 2 - 1, (index) {
            if (index.isOdd) {
              return const Divider(height: 1);
            }
            final tx = list[index ~/ 2];

            final hour = tx.transactionDate.hour.toString().padLeft(2, '0');
            final minute = tx.transactionDate.minute.toString().padLeft(2, '0');
            final timeStr = '$hour:$minute WIB';

            final catController = Get.find<CategoryController>();
            final categoryObj = catController.categories.firstWhereOrNull(
              (c) => c.id == tx.categoryId,
            );

            // Gunakan data dari kategori database
            final categoryName = categoryObj?.name ?? (tx.categoryName ?? 'Umum');
            final categoryIcon = categoryObj?.icon ?? tx.categoryIcon;
            final categoryColorHex = categoryObj?.colorHex ?? tx.categoryColorHex;

            final walletObj = controller.walletController.wallets
                .firstWhereOrNull((w) => w.id.toString() == tx.walletId);
            final walletName = walletObj?.name ?? 'Dompet';

            final prefix = tx.type == 'income' ? '+' : '-';
            final amountStr = '$prefix Rp ${_formatCurrency(tx.amount)}';

            return GestureDetector(
              onTap: () => Get.toNamed('/wallet/transaction/create', arguments: tx),
              behavior: HitTestBehavior.opaque,
              child: _buildTransactionRow(
                timeStr,
                tx.notes ?? categoryName,
                categoryName,
                walletName,
                amountStr,
                isExpense: tx.type == 'outcome',
                categoryIcon: categoryIcon,
                categoryColorHex: categoryColorHex,
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildTransactionRow(
    String time,
    String merchant,
    String category,
    String paymentMethod,
    String amount, {
    required bool isExpense,
    String? categoryIcon,
    String? categoryColorHex,
  }) {
    final icon = _getCategoryIcon(categoryIcon);
    final catColor = _parseColor(categoryColorHex);
    final iconBg = catColor.withOpacity(0.12);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  merchant.isNotEmpty ? '$merchant • $paymentMethod • $time' : '$paymentMethod • $time',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isExpense ? AppColors.error : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

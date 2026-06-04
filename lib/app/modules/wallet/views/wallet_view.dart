import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/wallet_model.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/wallet_controller.dart';
import 'package:lifesync_app/app/modules/wallet/components/wallet_card_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/header.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF1E293B);
    final hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF1E293B);
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      // New category icons
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

      // Old / fallback category icons
      case 'account_balance_wallet':
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'trending_up':
      case 'salary':
        return Icons.trending_up;
      case 'restaurant_outlined':
      case 'food':
        return Icons.restaurant_outlined;
      case 'shopping_bag':
      case 'shopping_bag_outlined':
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'directions_car':
      case 'directions_car_outlined':
      case 'transport':
        return Icons.directions_car_outlined;
      case 'medical_services':
      case 'medical_services_outlined':
      case 'health':
        return Icons.medical_services_outlined;
      case 'bolt':
      case 'bills':
        return Icons.bolt;
      case 'more_horiz':
      case 'others':
      default:
        return Icons.more_horiz;
    }
  }

  String _formatDateTime(DateTime dt) {
    final List<String> monthsShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = monthsShort[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final currentMonthName = months[DateTime.now().month - 1];
    final currentYear = DateTime.now().year;
    final periodText = 'Bulan $currentMonthName $currentYear';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Header(title: "User"),
                    const SizedBox(height: 32),
                    const Text(
                      'Dompet Saya',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kelola pengeluaran dan tabungan Anda dengan harmonis.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Wallet Carousel (Reactive)
              Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                return _buildWalletCarousel(controller.wallets);
              }),
              const SizedBox(height: 16),
              
              // Carousel Indicator (Reactive)
              Obx(() => _buildCarouselIndicator(controller.wallets.length + 1)),
              const SizedBox(height: 32),

              // Summary Cards (Pemasukan & Pengeluaran Reaktif Bulan Ini)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  final String incomeText = controller.totalIncomeThisMonth.value
                      .toStringAsFixed(0)
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      );
                  final String outcomeText = controller.totalOutcomeThisMonth.value
                      .toStringAsFixed(0)
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      );

                  return Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'PEMASUKAN',
                          '+ Rp $incomeText',
                          periodText,
                          const Color(0xFFE0F7F1),
                          const Color(0xFF10B981),
                          Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'PENGELUARAN',
                          '- Rp $outcomeText',
                          periodText,
                          const Color(0xFFFEE2E2),
                          const Color(0xFFEF4444),
                          Icons.trending_down,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Transaction History Section
              _buildTransactionHistory(),
              const SizedBox(height: 12),

              // Quick Action Button (Lihat Semua Transaksi)
              Obx(() {
                final filteredList = controller.transactions.where((tx) {
                  if (controller.selectedFilter.value == 'Pendapatan') {
                    return tx.type == 'income';
                  } else if (controller.selectedFilter.value == 'Pengeluaran') {
                    return tx.type == 'outcome';
                  }
                  return true;
                }).toList();

                if (filteredList.length > 4) {
                  return Center(
                    child: TextButton(
                      onPressed: () => Get.toNamed('/wallet/transaction'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Lihat Semua Transaksi',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 80), // Padding for bottom nav
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/wallet/transaction/create'),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWalletCarousel(List<WalletModel> wallets) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: wallets.length + 1, // +1 untuk tombol kartu baru
        itemBuilder: (context, index) {
          if (index == wallets.length) {
            return GestureDetector(
              onTap: () => Get.toNamed('/wallet/create'),
              child: _buildAddNewWalletCard(),
            );
          }

          final wallet = wallets[index];
          final color = _parseColor(wallet.colorHex);

          final String balanceText = (wallet.balance ?? 0.0)
              .toStringAsFixed(0)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]}.',
              );

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                controller.currentCarouselIndex.value = index;
              },
              child: WalletCardWidget(
                title: (wallet.name ?? '').toUpperCase(),
                balance: 'Rp $balanceText',
                backgroundColor: color,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddNewWalletCard() {
    return Container(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F7F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_card_outlined,
              size: 32,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tambah Dompet Baru',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kelola sumber dana lainnya',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicator(int totalSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSize, (index) {
        final isSelected = index == controller.currentCarouselIndex.value;
        return Container(
          width: isSelected ? 16 : 8,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.textSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    String period,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 6),
              AutoSizeText(
                label,
                minFontSize: 5,
                overflow: TextOverflow.ellipsis,
                maxFontSize: 11,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AutoSizeText(
            value,
            minFontSize: 5,
            maxLines: 1,
            maxFontSize: 16,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            period,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFilterTab('Semua'),
                const SizedBox(width: 12),
                _buildFilterTab('Pendapatan'),
                const SizedBox(width: 12),
                _buildFilterTab('Pengeluaran'),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              final filter = controller.selectedFilter.value;
              final filteredList = controller.transactions.where((tx) {
                if (filter == 'Pendapatan') {
                  return tx.type == 'income';
                } else if (filter == 'Pengeluaran') {
                  return tx.type == 'outcome';
                }
                return true;
              }).toList();

              if (filteredList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'Tidak ada transaksi',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                );
              }

              // Tampilkan maksimal 4 item
              final displayList = filteredList.take(4).toList();

              return Column(
                children: displayList.map((tx) {
                  final String sign = tx.type == 'income' ? '+' : '-';
                  final String amountText = tx.amount
                      .toStringAsFixed(0)
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      );

                  final iconColor = _parseColor(tx.categoryColorHex);
                  final iconBg = iconColor.withOpacity(0.12);

                  return GestureDetector(
                    onTap: () => Get.toNamed('/wallet/transaction/create', arguments: tx),
                    behavior: HitTestBehavior.opaque,
                    child: _buildTransactionItem(
                      tx.categoryName ?? 'Lain-lain',
                      '${_formatDateTime(tx.transactionDate)} • ${tx.notes ?? "Tanpa catatan"}',
                      '$sign Rp $amountText',
                      tx.categoryName ?? 'Kategori',
                      iconBg,
                      _getIconData(tx.categoryIcon),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      return GestureDetector(
        onTap: () => controller.selectedFilter.value = label,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.outline.withOpacity(0.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0369A1) : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    String category,
    Color iconBg,
    IconData icon,
  ) {
    bool isIncome = amount.startsWith('+');
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIncome
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

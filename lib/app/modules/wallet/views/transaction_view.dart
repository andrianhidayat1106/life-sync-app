import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/transaction_model.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/wallet_controller.dart';
import 'package:lifesync_app/core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';

class TransactionView extends GetView<WalletController> {
  const TransactionView({super.key});

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
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_outlined;
      case 'trending_up':
        return Icons.trending_up;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'bolt':
        return Icons.bolt;
      case 'more_horiz':
      default:
        return Icons.more_horiz;
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatGroupDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(dt.year, dt.month, dt.day);

    if (txDate == today) {
      return 'Hari Ini';
    } else if (txDate == yesterday) {
      return 'Kemarin';
    } else {
      final List<String> monthsFull = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${monthsFull[dt.month - 1]} ${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Transaksi"),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    _buildSearchBar(),
                  ],
                ),
              ),

              // 2. Summary Card
              _buildSummaryCard(),

              const SizedBox(height: 16),

              // 3. Grouped Transaction List (Reactive)
              Obx(() {
                final query = controller.searchQuery.value.toLowerCase();
                final filteredList = controller.transactions.where((tx) {
                  final matchesName = (tx.categoryName ?? '').toLowerCase().contains(query);
                  final matchesNotes = (tx.notes ?? '').toLowerCase().contains(query);
                  return matchesName || matchesNotes;
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        'Tidak ada transaksi ditemukan',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                      ),
                    ),
                  );
                }

                // Group transactions by date
                final Map<String, List<TransactionModel>> grouped = {};
                for (var tx in filteredList) {
                  final dateStr = _formatGroupDate(tx.transactionDate);
                  if (!grouped.containsKey(dateStr)) {
                    grouped[dateStr] = [];
                  }
                  grouped[dateStr]!.add(tx);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(entry.key),
                        ...entry.value.map((tx) {
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
                              '${tx.categoryName ?? "Finance"} • ${_formatTime(tx.transactionDate)} • ${tx.notes ?? "Tanpa catatan"}',
                              '$sign Rp $amountText',
                              iconBg,
                              _getIconData(tx.categoryIcon),
                              isExpense: tx.type == 'outcome',
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/wallet/transaction/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: const InputDecoration(
          hintText: 'Cari transaksi...',
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Deep Slate
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Obx(() {
          // Hitung total saldo bersih dari semua dompet
          final double netBalance = controller.wallets.fold(0.0, (sum, w) => sum + (w.balance ?? 0.0));
          final String netBalanceText = netBalance.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]}.',
              );

          final String incomeText = controller.totalIncomeThisMonth.value.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]}.',
              );

          final String outcomeText = controller.totalOutcomeThisMonth.value.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]}.',
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SALDO BERSIH TOTAL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp $netBalanceText',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildSummarySubItem(
                      'Pemasukan',
                      '+Rp $incomeText',
                      Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummarySubItem(
                      'Pengeluaran',
                      '-Rp $outcomeText',
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSummarySubItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white60),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    String amount,
    Color bgIcon,
    IconData icon, {
    required bool isExpense,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgIcon,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981), size: 24),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isExpense ? const Color(0xFFB91C1C) : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

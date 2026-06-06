import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/transaction_model.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/wallet_controller.dart';
import 'package:lifesync_app/core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helper.dart';

class TransactionView extends GetView<WalletController> {
  const TransactionView({super.key});

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF1E293B);
    final hex = hexString.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return const Color(0xFF1E293B);
  }

  IconData _getIconData(String? iconName) {
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
      default: return Icons.more_horiz;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatGroupDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(dt.year, dt.month, dt.day);
    if (txDate == today) return 'Hari Ini';
    if (txDate == yesterday) return 'Kemarin';
    final months = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDateLabel(DateTime dt) {
    final months = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agt','Sep','Okt','Nov','Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // ─── Apply Filters ────────────────────────────────────────────────────────

  List<TransactionModel> _applyFilters(List<TransactionModel> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final typeFilter = controller.selectedFilter.value;
    final dateFilter = controller.selectedDateFilter.value;
    final catFilter = controller.selectedCategoryFilter.value;
    final customDate = controller.customDateFilter.value;
    final query = controller.searchQuery.value.toLowerCase();

    return all.where((tx) {
      // Type filter
      if (typeFilter == 'Pendapatan' && tx.type != 'income') return false;
      if (typeFilter == 'Pengeluaran' && tx.type != 'outcome') return false;

      // Category filter
      if (catFilter.isNotEmpty && tx.categoryId != catFilter) return false;

      // Date filter
      final txDate = DateTime(tx.transactionDate.year, tx.transactionDate.month, tx.transactionDate.day);
      if (dateFilter == 'Hari Ini') {
        if (txDate != today) return false;
      } else if (dateFilter == '1 Minggu') {
        final weekAgo = today.subtract(const Duration(days: 6));
        if (txDate.isBefore(weekAgo)) return false;
      } else if (dateFilter == 'Bulan Ini') {
        if (tx.transactionDate.year != now.year || tx.transactionDate.month != now.month) return false;
      } else if (dateFilter == 'Pilih Tanggal' && customDate != null) {
        final picked = DateTime(customDate.year, customDate.month, customDate.day);
        if (txDate != picked) return false;
      }

      // Search
      if (query.isNotEmpty) {
        final matchName = (tx.categoryName ?? '').toLowerCase().contains(query);
        final matchNotes = (tx.notes ?? '').toLowerCase().contains(query);
        if (!matchName && !matchNotes) return false;
      }

      return true;
    }).toList();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Refresh data on entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });

    return Scaffold(
      appBar: CustomAppBar(title: 'Transaksi'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 12),

            // ── Summary Card ─────────────────────────────────────────────────
            _buildSummaryCard(),
            const SizedBox(height: 16),

            // ── Filter Row: Type ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() => Row(
                children: ['Semua', 'Pendapatan', 'Pengeluaran'].map((label) {
                  final isSelected = controller.selectedFilter.value == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => controller.selectedFilter.value = label,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (label == 'Pendapatan'
                                  ? const Color(0xFF10B981)
                                  : label == 'Pengeluaran'
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF0F172A))
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.outline.withOpacity(0.4),
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))]
                              : [],
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
            ),
            const SizedBox(height: 10),

            // ── Filter Row: Date Range ─────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: ['Semua', 'Hari Ini', '1 Minggu', 'Bulan Ini', 'Pilih Tanggal'].map((label) {
                  return Obx(() {
                    final isSelected = controller.selectedDateFilter.value == label;
                    final isDatePicker = label == 'Pilih Tanggal';
                    final pickedDate = controller.customDateFilter.value;
                    final displayLabel = (isDatePicker && pickedDate != null)
                        ? _formatDateLabel(pickedDate)
                        : label;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () async {
                          if (isDatePicker) {
                            final picked = await UIHelper.showCustomDatePicker(
                              initialDate: controller.customDateFilter.value ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              controller.customDateFilter.value = picked;
                              controller.selectedDateFilter.value = 'Pilih Tanggal';
                            }
                          } else {
                            controller.selectedDateFilter.value = label;
                            controller.customDateFilter.value = null;
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppColors.outline.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isDatePicker)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              Text(
                                displayLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // ── Filter Row: Category ────────────────────────────────────────
            Obx(() {
              if (controller.categories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // "Semua" chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Obx(() {
                        final isSelected = controller.selectedCategoryFilter.value.isEmpty;
                        return GestureDetector(
                          onTap: () => controller.selectedCategoryFilter.value = '',
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : AppColors.outline.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              'Semua Kategori',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    // Category chips
                    ...controller.categories.map((cat) {
                      return Obx(() {
                        final isSelected = controller.selectedCategoryFilter.value == cat.id;
                        final catColor = _parseColor(cat.colorHex);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => controller.selectedCategoryFilter.value = cat.id ?? '',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? catColor : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : AppColors.outline.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getIconData(cat.icon),
                                    size: 12,
                                    color: isSelected ? Colors.white : catColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    }),
                  ],
                ),
              );
            }),

            // ── Divider ──────────────────────────────────────────────────────
            const SizedBox(height: 8),
            Divider(height: 1, color: AppColors.outline.withOpacity(0.2)),

            // ── Transaction List ─────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final filtered = _applyFilters(controller.transactions.toList());

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textSecondary.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada transaksi ditemukan',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coba ubah filter atau tambah transaksi baru',
                          style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final Map<String, List<TransactionModel>> grouped = {};
                for (var tx in filtered) {
                  final key = _formatGroupDate(tx.transactionDate);
                  grouped.putIfAbsent(key, () => []).add(tx);
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(entry.key),
                        ...entry.value.map((tx) {
                          final sign = tx.type == 'income' ? '+' : '-';
                          final amountText = tx.amount
                              .toStringAsFixed(0)
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (m) => '${m[1]}.',
                              );
                          final iconColor = _parseColor(tx.categoryColorHex);
                          final iconBg = iconColor.withOpacity(0.12);

                          return GestureDetector(
                            onTap: () => Get.toNamed('/wallet/transaction/create', arguments: tx),
                            behavior: HitTestBehavior.opaque,
                            child: _buildTransactionItem(
                              tx.categoryName ?? 'Lain-lain',
                              '${_formatTime(tx.transactionDate)} • ${tx.notes ?? "Tanpa catatan"}',
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/wallet/transaction/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ─── Sub-Widgets ───────────────────────────────────────────────────────────

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
          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Obx(() {
          final netBalance = controller.wallets.fold(0.0, (sum, w) => sum + (w.balance ?? 0.0));
          final netBalanceText = netBalance.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
          final incomeText = controller.totalIncomeThisMonth.value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
          final outcomeText = controller.totalOutcomeThisMonth.value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SALDO TOTAL',
                style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 6),
              Text(
                'Rp $netBalanceText',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummarySubItem('Pemasukan', '+Rp $incomeText', Icons.arrow_downward, const Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummarySubItem('Pengeluaran', '-Rp $outcomeText', Icons.arrow_upward, const Color(0xFFEF4444)),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSummarySubItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 3),
              Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgIcon, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
              color: isExpense ? const Color(0xFFB91C1C) : const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary.withOpacity(0.4)),
        ],
      ),
    );
  }
}

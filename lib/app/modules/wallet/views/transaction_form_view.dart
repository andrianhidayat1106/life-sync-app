import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/transaction_controller.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/wallet_controller.dart';
import '../../../../core/constants/app_colors.dart';

class TransactionFormView extends GetView<TransactionController> {
  const TransactionFormView({super.key});

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

  String _formatDate(DateTime dt) {
    final List<String> monthsShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = monthsShort[dt.month - 1];
    final year = dt.year;
    return '$day $month $year';
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
              controller.isEditMode.value ? 'Edit Transaksi' : 'Tambah Transaksi',
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
                    title: 'Hapus Transaksi',
                    middleText: 'Apakah Anda yakin ingin menghapus transaksi ini?',
                    textConfirm: 'Hapus',
                    textCancel: 'Batal',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () {
                      Get.back(); // Tutup dialog
                      Get.find<WalletController>().deleteTransaction(controller.editTransaction!.id!);
                      Get.back(); // Kembali ke halaman utama
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
              // 1. Toggle Pengeluaran / Pemasukan
              Obx(() => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildToggleOption(
                            'Pengeluaran',
                            !controller.isIncome.value,
                            () => controller.isIncome.value = false,
                          ),
                        ),
                        Expanded(
                          child: _buildToggleOption(
                            'Pemasukan',
                            controller.isIncome.value,
                            () => controller.isIncome.value = true,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 40),

              // 2. Input Nominal (Large)
              Center(
                child: Column(
                  children: [
                    const Text(
                      'JUMLAH NOMINAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Rp',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 60),
                              child: IntrinsicWidth(
                                child: TextField(
                                  controller: controller.amountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    ThousandsFormatter(),
                                  ],
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: AppColors.textPrimary.withOpacity(0.3),
                                    ),
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(
                      width: 160,
                      child: Divider(thickness: 2, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 3. Kategori
              _buildSectionHeader('Kategori'),
              const SizedBox(height: 16),
              Obx(() {
                final list = controller.filteredCategories;
                final selectedId = controller.selectedCategoryId.value;
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Kategori tidak ditemukan', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final cat = list[index];
                      final isSelected = selectedId == cat.id;
                      return GestureDetector(
                        onTap: () => controller.selectedCategoryId.value = cat.id ?? '',
                        child: _buildCategoryItem(
                          _getIconData(cat.icon),
                          cat.name,
                          isSelected,
                          cat.colorHex,
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 32),

              // 4. Pilih Dompet
              const Text(
                'Pilih Dompet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final list = controller.wallets;
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Harap tambahkan dompet terlebih dahulu', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return Row(
                  children: list.map((wallet) {
                    final isSelected = controller.selectedWalletId.value == wallet.id.toString();
                    final balanceText = (wallet.balance ?? 0.0)
                        .toStringAsFixed(0)
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        );

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () => controller.selectedWalletId.value = wallet.id.toString(),
                          child: _buildWalletOption(
                            wallet.name ?? 'Dompet',
                            'Rp $balanceText',
                            Icons.account_balance_wallet,
                            isSelected,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 32),

              // 5. Tanggal & Catatan
              _buildLabel('Tanggal'),
              const SizedBox(height: 12),
              Obx(() {
                final dateText = _formatDate(controller.selectedDate.value);
                return _buildDateField(dateText, () => controller.selectDate(context));
              }),

              const SizedBox(height: 24),
              _buildLabel('Catatan'),
              const SizedBox(height: 12),
              _buildInputField(
                icon: Icons.notes,
                hint: 'Tambahkan deskripsi transaksi...',
                textController: controller.notesController,
                isMultiline: true,
              ),

              const SizedBox(height: 48),

              // 6. Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.saveTransaction(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        controller.isLoading.value
                            ? 'Menyimpan...'
                            : (controller.isEditMode.value ? 'Simpan Perubahan' : 'Simpan Transaksi'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
      ],
    );
  }

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
    return const Color(0xFF1E293B);
  }

  Widget _buildCategoryItem(IconData icon, String label, bool isSelected, String colorHex) {
    final catColor = _parseColor(colorHex);
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? catColor.withOpacity(0.15) : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: catColor, width: 1.5) : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? catColor : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOption(
    String name,
    String detail,
    IconData icon,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.outline.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  Widget _buildDateField(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    TextEditingController? textController,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: textController,
              maxLines: isMultiline ? 3 : 1,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Hanya ambil angka
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    // Tambahkan titik setiap 3 digit dari belakang
    String formatted = '';
    int count = 0;
    for (int i = cleanText.length - 1; i >= 0; i--) {
      formatted = cleanText[i] + formatted;
      count++;
      if (count == 3 && i > 0) {
        formatted = '.$formatted';
        count = 0;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/wallet_controller.dart';
import 'package:lifesync_app/app/modules/wallet/components/wallet_card_widget.dart';
import '../../../../core/constants/app_colors.dart';

class WalletFormView extends GetView<WalletController> {
  const WalletFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> availableColorsHex = [
      '1E3A8A', // Blue
      '10B981', // Green
      'F59E0B', // Amber
      'EF4444', // Red
      '6B7280', // Gray
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Tambah Dompet Baru',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Visual Card Preview (Reactive)
              Center(
                child: Obx(() {
                  final name = controller.previewName.value;
                  final balance = controller.previewBalance.value;
                  final colorHex = controller.selectedColorHex.value;
                  final color = Color(int.parse('FF$colorHex', radix: 16));

                  return WalletCardWidget(
                    title: name,
                    balance: 'Rp $balance',
                    backgroundColor: color,
                  );
                }),
              ),
              const SizedBox(height: 32),

              // 2. Pemilih Tema Warna (Reactive)
              _buildLabel('Tema Warna'),
              const SizedBox(height: 16),
              _buildColorSelector(availableColorsHex),
              const SizedBox(height: 40),

              // 3. Form Input
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Dompet'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.walletNameController,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: BCA Prioritas',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Saldo Awal'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.initialBalanceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        hintText: '0',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 4. Tombol Simpan
              _buildActionButtons(context),
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
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildColorSelector(List<String> hexCodes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: hexCodes.map((hex) {
        final color = Color(int.parse('FF$hex', radix: 16));
        return Obx(() {
          final isSelected = controller.selectedColorHex.value == hex;
          return GestureDetector(
            onTap: () => controller.selectColor(hex),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.black, width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.addNewWallet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                controller.isLoading.value ? 'Menyimpan...' : 'Simpan Dompet',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

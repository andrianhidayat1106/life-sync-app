import 'package:flutter/material.dart';
import 'package:lifesync_app/app/modules/wallet/components/wallet_card_widget.dart';
import '../../../../core/constants/app_colors.dart';

class WalletFormView extends StatelessWidget {
  const WalletFormView({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: WalletCardWidget(
                  title: "Dompet Utama",
                  balance: "Rp 15.450.000",
                  backgroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              // 2. Pemilih Tema Warna
              _buildLabel('Tema Warna'),
              const SizedBox(height: 16),
              _buildColorSelector(),
              const SizedBox(height: 40),

              // 3. Form Input Minimalis
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
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Contoh: BCA Prioritas',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Saldo Awal'),
                    const SizedBox(height: 12),
                    const TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '0',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 4. Tombol Aksi
              _buildActionButtons(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    final colors = [
      const Color(0xFF0F172A), // Slate
      const Color(0xFF065F46), // Emerald
      const Color(0xFF7DD3FC), // Light Blue
      const Color(0xFFB91C1C), // Red
      const Color(0xFF334155), // Grayish Slate
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: colors.map((color) {
        bool isSelected = color == colors[0]; // Visual default
        return Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      }).toList(),
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Simpan Dompet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

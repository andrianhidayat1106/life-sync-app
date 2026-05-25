import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TransactionFormView extends StatelessWidget {
  const TransactionFormView({super.key});

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
          'Tambah Transaksi',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Toggle Pengeluaran / Pemasukan
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildToggleOption('Pengeluaran', true)),
                    Expanded(child: _buildToggleOption('Pemasukan', false)),
                  ],
                ),
              ),
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

                    // 1. Bungkus dengan Padding horizontal agar tidak menempel pas di pinggir layar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: FittedBox(
                        fit: BoxFit
                            .scaleDown, // KUNCI UTAMA: Otomatis mengecilkan font jika ruang tidak cukup
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
                              // Berikan minWidth standar agar saat kosong ('0') area ketik tidak terlalu kecil
                              constraints: const BoxConstraints(minWidth: 60),
                              child: IntrinsicWidth(
                                child: TextField(
                                  // controller: controller.nominalController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize:
                                        56, // Tetap gunakan font besar untuk nominal kecil
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: AppColors.textPrimary.withOpacity(
                                        0.3,
                                      ),
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
              _buildSectionHeader('Kategori', 'Lihat Semua'),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryItem(Icons.restaurant, 'Food', true),
                    _buildCategoryItem(
                      Icons.shopping_bag_outlined,
                      'Shop',
                      false,
                    ),
                    _buildCategoryItem(
                      Icons.directions_car_outlined,
                      'Trans',
                      false,
                    ),
                    _buildCategoryItem(
                      Icons.medical_services_outlined,
                      'Health',
                      false,
                    ),
                  ],
                ),
              ),
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
              Row(
                children: [
                  Expanded(
                    child: _buildWalletOption(
                      'Tabungan Utama',
                      'Rp 12.500.000',
                      Icons.account_balance_wallet,
                      true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildWalletOption(
                      'Kartu Kredit',
                      'Limit Rp 5.00',
                      Icons.credit_card,
                      false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 5. Tanggal & Catatan
              _buildLabel('Tanggal'),
              const SizedBox(height: 12),
              _buildInputField(
                Icons.calendar_today_outlined,
                'Today, 24 May 2024',
              ),

              const SizedBox(height: 24),
              _buildLabel('Catatan'),
              const SizedBox(height: 12),
              _buildInputField(
                Icons.notes,
                'Tambahkan deskripsi transaksi...',
                isMultiline: true,
              ),

              const SizedBox(height: 48),

              // 6. Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return Container(
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
    );
  }

  Widget _buildSectionHeader(String title, String action) {
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
        Text(
          action,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, bool isSelected) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE0F7F1)
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: AppColors.secondary, width: 1.5)
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.secondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
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
          color: isSelected
              ? AppColors.secondary
              : AppColors.outline.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary
                  : AppColors.surfaceContainer,
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

  Widget _buildInputField(
    IconData icon,
    String hint, {
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              maxLines: isMultiline ? 3 : 1,
            ),
          ),
        ],
      ),
    );
  }
}

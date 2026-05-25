import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/modules/project/controllers/project_controller.dart';
import '../../../../core/constants/app_colors.dart';

class ProjectFormView extends GetView<ProjectController> {
  const ProjectFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor:
            AppColors.background, // Menyelaraskan background AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Proyek Baru',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Proyek Baru',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rencanakan langkah besar Anda berikutnya dengan detail yang terstruktur.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Form Utama
              _buildLabel('Nama Proyek'),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Contoh: Renovasi Kantor Pusat',
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Deskripsi'),
              const SizedBox(height: 8),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan tujuan utama dan lingkup proyek ini...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Kategori
              _buildLabel('Kategori'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTag('Pekerjaan', true),
                  _buildTag('Pribadi', false),
                  _buildTag('Keuangan', false),
                  _buildTag('Kesehatan', false),
                ],
              ),
              const SizedBox(height: 32),

              // Prioritas
              _buildLabel('Prioritas'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(child: _buildPriorityOption('Rendah', false)),
                    Expanded(child: _buildPriorityOption('Sedang', true)),
                    Expanded(child: _buildPriorityOption('Tinggi', false)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tenggat Waktu
              _buildLabel('Tenggat Waktu'),
              const SizedBox(height: 12),
              const TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'mm/dd/yyyy',
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // SEKSI TUGAS AWAL
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors
                      .white, // Putih konvensional untuk kartu/kontainer di atas background abu-abu
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tambah Tugas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OPSIONAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildInitialTaskField(
                      hint: 'Langkah pertama...',
                      showDelete: true,
                    ),
                    const SizedBox(height: 20),

                    // Tombol Tambah Baris Baru
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppColors.success,
                        ),
                        label: const Text(
                          'Tambah Tugas Baru',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: AppColors.success.withOpacity(0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Tombol Aksi Akhir
              // Tombol Aksi Akhir
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors
                        .primary, // Sekarang menggunakan Slate-900 (Primary)
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Simpan Proyek',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .white, // Teks putih agar kontras di atas warna gelap
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

  Widget _buildTag(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.success.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? AppColors.success : AppColors.outline,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.success : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white
            : Colors.transparent, // Tetap transparan jika tidak terpilih
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(
                    0.05,
                  ), // Menggunakan textPrimary tipis untuk shadow
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialTaskField({
    required String hint,
    bool showDelete = true,
    // Sediakan parameter tambahan jika statusnya dinamis dari controller, contoh:
    // required int index,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mengganti Icon Drag menjadi Checkbox yang Sejajar
        Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
          ), // Menyelaraskan posisi vertikal dengan teks di dalam TextField
          child: SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              // Contoh implementasi reaktif dengan GetX:
              // value: controller.initialTasks[index].isCompleted.value,
              value: true, // Ganti dengan variabel Rx dari controller Anda
              onChanged: (bool? value) {
                // Contoh aksi:
                // controller.toggleTaskStatus(index, value);
              },
              activeColor: AppColors.success, // Emerald-500 saat aktif
              checkColor: Colors.white,
              side: const BorderSide(
                color: AppColors.outline, // Border biru pucat saat kosong
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  6,
                ), // Membuat sudut kotak sedikit membulat (modern)
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: showDelete
                  ? Container(
                      height: 48,
                      alignment: Alignment.center,
                      width: 40,
                      child: IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(right: 4.0),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          size: 20,
                          color: AppColors
                              .error, // Menggunakan warna merah semantic
                        ),
                        onPressed: () {
                          // Aksi hapus baris tugas di sini via controller
                        },
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

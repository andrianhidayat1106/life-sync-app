import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Notifikasi"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today Section
              _buildSectionHeader('Hari Ini'),
              _buildNotificationItem(
                'Pembayaran Berhasil',
                'Tagihan Listrik bulan Oktober sebesar Rp 850.000 telah terbayar otomatis.',
                '10:30 WIB',
                Icons.check_circle_outline,
                const Color(0xFFE0F7F1),
                const Color(0xFF10B981),
                isUnread: true,
              ),
              _buildNotificationItem(
                'Tugas Terlewati',
                'Jangan lupa selesaikan "Review Desain Sprint 2" yang sudah lewat tenggat waktu.',
                '09:00 WIB',
                Icons.priority_high_outlined,
                const Color(0xFFFEE2E2),
                const Color(0xFFEF4444),
                isUnread: true,
              ),

              const SizedBox(height: 16),

              // Yesterday Section
              _buildSectionHeader('Kemarin'),
              _buildNotificationItem(
                'Proyek Baru Ditambahkan',
                'Anda telah membuat proyek "Optimasi Database SQL". Mari mulai bekerja!',
                'Kemarin, 14:20 WIB',
                Icons.assignment_outlined,
                const Color(0xFFEFF4FF),
                const Color(0xFF0C54BE),
              ),
              _buildNotificationItem(
                'Laporan Mingguan',
                'Ringkasan aktivitas keuangan dan produktivitas minggu lalu sudah siap dilihat.',
                'Kemarin, 08:00 WIB',
                Icons.insights_outlined,
                const Color(0xFFF3E8FF),
                const Color(0xFF7E22CE),
              ),

              const SizedBox(height: 16),

              // Earlier Section
              _buildSectionHeader('Sebelumnya'),
              _buildNotificationItem(
                'Keamanan Akun',
                'Kata sandi akun Anda berhasil diubah. Jika ini bukan Anda, segera hubungi dukungan.',
                '2 hari lalu',
                Icons.shield_outlined,
                const Color(0xFFF8F9FF),
                const Color(0xFF0F172A),
              ),

              const SizedBox(height: 100), // Spacing for safe area
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String body,
    String time,
    IconData icon,
    Color bgIcon,
    Color iconColor, {
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgIcon,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

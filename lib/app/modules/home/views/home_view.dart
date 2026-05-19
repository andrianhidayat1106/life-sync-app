import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(),
              const SizedBox(height: 24),

              // Consolidated Balance Card
              _buildBalanceCard(),
              const SizedBox(height: 32),

              // Active Projects Section
              _buildSectionHeader('Proyek Aktif', 'Lihat Semua', () {}),
              const SizedBox(height: 16),
              _buildProjectCarousel(),
              const SizedBox(height: 32),

              // Today's Tasks Section
              _buildSectionHeader('Tugas Hari Ini', 'Kelola Tugas', () {}),
              const SizedBox(height: 16),
              _buildTaskList(),
              const SizedBox(height: 32),

              // Recent Activity Section
              _buildSectionHeader('Aktivitas Terakhir', 'Lihat Semua', () {}),
              const SizedBox(height: 16),
              _buildRecentActivityList(),
              const SizedBox(height: 80), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Harmoni Hidup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_outlined),
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
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
          const Text(
            'Rp 128.450.000',
            style: TextStyle(
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
                  'Rp 15.200.000',
                  const Color(0xFFE0F7F1),
                  const Color(0xFF10B981),
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceSummaryItem(
                  'PENGELUARAN',
                  'Rp 8.450.000',
                  const Color(0xFFFEE2E2),
                  const Color(0xFFEF4444),
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart Placeholder (Visual Bars)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar(30, Colors.tealAccent.withOpacity(0.4)),
              _buildChartBar(50, Colors.tealAccent.withOpacity(0.4)),
              _buildChartBar(35, Colors.tealAccent.withOpacity(0.4)),
              _buildChartBar(60, Colors.tealAccent.withOpacity(0.4)),
              _buildChartBar(90, const Color(0xFF0C54BE)),
              _buildChartBar(55, Colors.tealAccent.withOpacity(0.4)),
              _buildChartBar(65, Colors.tealAccent.withOpacity(0.4)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              const Text(
                '+12.5% dari bulan lalu',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Analisis Detail'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C54BE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
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
            style: TextStyle(
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
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCarousel() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildProjectCard('Renovasi Dapur', 0.75, Icons.home_work_outlined),
          _buildProjectCard(
            'Investasi Saham',
            0.40,
            Icons.trending_up_outlined,
          ),
        ],
      ),
    );
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
    return Column(
      children: [
        _buildTaskItem('Bayar Tagihan Listrik', 'Keuangan • Mendesak', false),
        _buildTaskItem('Olahraga Pagi', 'Kesehatan • Selesai', true),
        _buildTaskItem('Review Anggaran Bulanan', 'Keuangan • Hari Ini', false),
      ],
    );
  }

  Widget _buildTaskItem(String title, String subtitle, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: 16),
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
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildActivityItem(
            'Supermarket Harmoni',
            'Belanja Bulanan • 10:24 WIB',
            '- Rp 450.000',
            Colors.red,
            Icons.shopping_bag_outlined,
          ),
          const Divider(height: 1),
          _buildActivityItem(
            'Transfer Masuk',
            'Dividen Saham • Kemarin',
            '+ Rp 1.200.000',
            Colors.teal,
            Icons.account_balance_outlined,
          ),
          const Divider(height: 1),
          _buildActivityItem(
            'Kedai Kopi Pagi',
            'Gaya Hidup • Kemarin',
            '- Rp 35.000',
            Colors.red,
            Icons.coffee_outlined,
          ),
          const Divider(height: 1),
          _buildActivityItem(
            'PLN Pascabayar',
            'Utilitas • 2 Hari Lalu',
            '- Rp 850.000',
            Colors.red,
            Icons.bolt,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String amount,
    Color amountColor,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0C54BE), size: 20),
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
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

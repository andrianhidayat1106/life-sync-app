import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TaskView extends StatelessWidget {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(),
              const SizedBox(height: 24),

              // Calendar Navigation with "Hari Ini" Reset
              _buildCalendarNav(),
              const SizedBox(height: 32),

              // Daily Progress Card
              _buildProgressCard(),
              const SizedBox(height: 32),

              // Filter Chips
              _buildFilterChips(),
              const SizedBox(height: 24),

              // Task List
              _buildTaskList(),
              const SizedBox(height: 32),

              // Bottom Spacing for Navigation
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // Floating Action Button for New Task
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
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
              const Text(
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
      ),
    );
  }

  Widget _buildCalendarNav() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month Picker with Arrow
              Row(
                children: [
                  const Text(
                    'Oktober 2023',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                ],
              ),
              // Reset "Hari Ini" Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Hari Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Horizontal Date Scroller
        SizedBox(
          height: 94,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildDateItem('Sen', '23', false),
              _buildDateItem('Sel', '24', false),
              _buildDateItem(
                'Rab',
                '25',
                true,
              ), // Selected Date (Emerald Green)
              _buildDateItem('Kam', '26', false),
              _buildDateItem('Jum', '27', false),
              _buildDateItem('Sab', '28', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(String day, String date, bool isSelected) {
    return Container(
      width: 66,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF065F46) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF065F46)
              : AppColors.outline.withOpacity(0.3),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF065F46).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progres Harian',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kamu telah menyelesaikan 8 dari 12 tugas hari ini. Sedikit lagi!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: 0.66,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFEFF4FF),
                    strokeCap: StrokeCap.round,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF065F46),
                    ),
                  ),
                ),
                const Text(
                  '66%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildChip('Semua', true),
          _buildChip('Keuangan', false),
          _buildChip('Proyek', false),
          _buildChip('Pribadi', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildTaskItem(
            'Bayar Tagihan Listrik',
            'Selesaikan sebelum jam 17:00 WIB.',
            'KEUANGAN',
            const Color(0xFFDBEAFE),
            const Color(0xFF1E40AF),
            true, // Completed
            trailingIcon: Icons.more_vert,
          ),
          _buildTaskItem(
            'Review Desain Sprint 2',
            'Hubungi tim UI/UX untuk sinkronisasi aset.',
            'PROYEK',
            const Color(0xFFF3E8FF),
            const Color(0xFF7E22CE),
            false,
            priority: 'Prioritas Tinggi',
            trailingIcon: Icons.outlined_flag,
          ),
          _buildTaskItem(
            'Latihan Yoga Sore',
            '30 menit sesi vinyasa flow di rumah.',
            'PRIBADI',
            const Color(0xFFDCFCE7),
            const Color(0xFF15803D),
            false,
            time: '16:30 WIB',
            trailingIcon: Icons.access_time,
          ),
          _buildTaskItem(
            'Kirim Laporan Mingguan',
            'Dikirim ke Manajer Proyek melalui Email.',
            'PROYEK',
            const Color(0xFFF3E8FF),
            const Color(0xFF7E22CE),
            true,
            trailingIcon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    String title,
    String subtitle,
    String category,
    Color categoryBg,
    Color categoryText,
    bool isDone, {
    String? priority,
    String? time,
    IconData? trailingIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Checkbox
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF065F46) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDone
                    ? const Color(0xFF065F46)
                    : AppColors.textSecondary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: categoryBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: categoryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (priority != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        priority,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (time != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}

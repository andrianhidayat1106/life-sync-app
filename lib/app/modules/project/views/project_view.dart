import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProjectView extends StatelessWidget {
  const ProjectView({super.key});

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
              const SizedBox(height: 32),

              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proyek Berjalan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pantau kemajuan dan kelola sumber daya proyek Anda dengan efisien.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Featured Project Card (Main)
              _buildMainProjectCard(),
              const SizedBox(height: 24),

              // Secondary Projects List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildProjectCard(
                      'Redesain UI Harmoni',
                      'Pembaruan sistem desain untuk aplikasi mobile agar lebih selaras dengan brand identity baru.',
                      0.40,
                      '40%',
                      '5 Tugas Tersisa',
                      [
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                        'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100',
                      ],
                      '+3',
                    ),
                    const SizedBox(height: 16),
                    _buildProjectCard(
                      'Audit Keamanan Tahunan',
                      'Pemeriksaan menyeluruh terhadap protokol keamanan internal dan penetrasi sistem.',
                      0.90,
                      '90%',
                      '2 Tugas Tersisa',
                      [
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
                      ],
                      '+1',
                    ),
                    const SizedBox(height: 16),
                    _buildProjectCard(
                      'Optimasi Database SQL',
                      'Meningkatkan kecepatan query dan efisiensi penyimpanan untuk laporan bulanan.',
                      0.15,
                      '15%',
                      '18 Tugas Tersisa',
                      [
                        'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100',
                      ],
                      '+4',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // External Project Card
              _buildExternalProjectCard(),

              // Bottom Spacing for Navigation
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Floating Action Button
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
                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
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

  Widget _buildMainProjectCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saya',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Prioritas Tinggi',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Modernisasi Infrastruktur Cloud',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Migrasi seluruh arsitektur basis data ke sistem hybrid cloud untuk meningkatkan skalabilitas dan keamanan data korporat di seluruh cabang.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kemajuan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Text(
                  '75%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: 0.75,
                minHeight: 10,
                backgroundColor: Color(0xFFEFF4FF),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF065F46)),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEFF4FF)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  '12 Tugas Tersisa',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Icon(
                  Icons.group_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  '8 Anggota',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Detail',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    String title,
    String description,
    double progress,
    String progressLabel,
    String tasks,
    List<String> avatars,
    String extraAvatars,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Saya',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kemajuan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                progressLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFEFF4FF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF065F46),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                tasks,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // FIXED: Wrap Stack in a sized container to provide finite constraints
              SizedBox(
                height: 28,
                width: 100, // Explicit width for the avatar stack
                child: Stack(
                  children: [
                    for (int i = 0; i < avatars.length; i++)
                      Positioned(
                        left: i * 18.0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(avatars[i]),
                          ),
                        ),
                      ),
                    Positioned(
                      left: avatars.length * 18.0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            extraAvatars,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C54BE),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExternalProjectCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7F1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Eksternal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C54BE),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kampanye Digital Q4',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Strategi pemasaran terintegrasi untuk meluncurkan layanan berlangganan baru ke pasar Asia Tenggara.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status: 55% Selesai',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text('9 Tugas Tersisa', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.55,
                  minHeight: 8,
                  backgroundColor: Color(0xFFEFF4FF),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF065F46)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

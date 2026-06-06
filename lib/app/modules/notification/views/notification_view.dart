import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/notification_model.dart';
import 'package:lifesync_app/app/modules/notification/controllers/notification_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "Notifikasi"),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF065F46)),
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_none_outlined,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tidak Ada Notifikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum ada laporan harian atau pengingat masuk. Rencana aktivitas Anda akan terwujud di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final now = DateTime.now();
          final todayList = <NotificationModel>[];
          final yesterdayList = <NotificationModel>[];
          final earlierList = <NotificationModel>[];

          for (var n in controller.notifications) {
            if (n.createdAt == null) {
              earlierList.add(n);
              continue;
            }
            final date = n.createdAt!.toLocal();
            final isToday = date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            final isYesterday = date.year == now.year &&
                date.month == now.month &&
                date.day == now.subtract(const Duration(days: 1)).day;

            if (isToday) {
              todayList.add(n);
            } else if (isYesterday) {
              yesterdayList.add(n);
            } else {
              earlierList.add(n);
            }
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadNotificationsFlow(),
            color: const Color(0xFF065F46),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todayList.isNotEmpty) ...[
                    _buildSectionHeader('Hari Ini'),
                    ...todayList.map((n) => _buildItemWidget(n, 'today')),
                  ],
                  if (yesterdayList.isNotEmpty) ...[
                    _buildSectionHeader('Kemarin'),
                    ...yesterdayList.map((n) => _buildItemWidget(n, 'yesterday')),
                  ],
                  if (earlierList.isNotEmpty) ...[
                    _buildSectionHeader('Sebelumnya'),
                    ...earlierList.map((n) => _buildItemWidget(n, 'earlier')),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        }),
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

  Widget _buildItemWidget(NotificationModel n, String section) {
    final iconData = _getIconData(n.icon);
    final bgIcon = _getIconBgColor(n.icon);
    final iconColor = _getIconAccentColor(n.icon);
    final timeStr = _formatTime(n.createdAt, section);

    return _buildNotificationItem(
      n.title,
      n.body,
      timeStr,
      iconData,
      bgIcon,
      iconColor,
      isUnread: n.isUnread,
    );
  }

  String _formatTime(DateTime? dt, String section) {
    if (dt == null) return '';
    final localDt = dt.toLocal();
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');

    if (section == 'today') {
      return '$hour:$minute WIB';
    } else if (section == 'yesterday') {
      return 'Kemarin, $hour:$minute WIB';
    } else {
      final List<String> monthsShort = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agt',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${localDt.day} ${monthsShort[localDt.month - 1]} ${localDt.year}, $hour:$minute WIB';
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'insights_outlined':
      case 'insights':
        return Icons.insights_outlined;
      case 'assignment_outlined':
      case 'assignment':
        return Icons.assignment_outlined;
      case 'check_circle_outline':
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'error_outline':
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getIconBgColor(String? iconName) {
    switch (iconName) {
      case 'insights_outlined':
      case 'insights':
        return const Color(0xFFF3E8FF);
      case 'assignment_outlined':
      case 'assignment':
        return const Color(0xFFEFF4FF);
      case 'check_circle_outline':
      case 'check_circle':
        return const Color(0xFFE0F7F1);
      case 'error_outline':
      case 'error':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getIconAccentColor(String? iconName) {
    switch (iconName) {
      case 'insights_outlined':
      case 'insights':
        return const Color(0xFF7E22CE);
      case 'assignment_outlined':
      case 'assignment':
        return const Color(0xFF0C54BE);
      case 'check_circle_outline':
      case 'check_circle':
        return const Color(0xFF10B981);
      case 'error_outline':
      case 'error':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
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
        color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgIcon,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
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
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.w600,
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
                  style: const TextStyle(
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

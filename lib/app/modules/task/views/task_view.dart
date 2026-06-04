import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/core/widgets/header.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/task_controller.dart';
import 'package:lifesync_app/app/data/models/task_model.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});

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
    return const Color(0xFF6B7280);
  }

  String _formatFinishedAt(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    
    final List<String> monthsShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = monthsShort[dt.month - 1];
    return '$day $month ${dt.year}, $hour:$minute WIB';
  }

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
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 24,
                  left: 24,
                  right: 24,
                ),
                child: Header(title: controller.getUserFullName()),
              ),

              // Calendar Navigation with DatePicker & "Hari Ini" Reset
              _buildCalendarNav(context),
              const SizedBox(height: 32),

              // Daily Progress Card
              _buildProgressCard(),
              const SizedBox(height: 32),

              // Filter Chips (Productivity Kategori)
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
        onPressed: () {
          controller.prepareCreateForm();
          Get.toNamed('/task/create');
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarNav(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month Picker with Arrow
              GestureDetector(
                onTap: () => controller.selectDateFromPicker(context),
                child: Row(
                  children: [
                    Obx(() {
                      final date = controller.selectedDate.value;
                      final List<String> monthsFull = [
                        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                      ];
                      return Text(
                        '${monthsFull[date.month - 1]} ${date.year}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              // Reset "Hari Ini" Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () => controller.resetToToday(),
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
          child: Obx(() {
            final List<String> weekdaysShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
            final weekDaysList = controller.weekDays;
            return ListView.builder(
              controller: controller.scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: weekDaysList.length,
              itemBuilder: (context, index) {
                final dayDate = weekDaysList[index];
                final dayName = weekdaysShort[dayDate.weekday - 1];
                final dateStr = dayDate.day.toString();
                final isSelected = controller.isSameDate(dayDate, controller.selectedDate.value);
                return GestureDetector(
                  onTap: () => controller.selectDate(dayDate),
                  child: _buildDateItem(dayName, dateStr, isSelected),
                );
              },
            );
          }),
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
        child: Obx(() {
          final pct = controller.dailyProgressPercentage;
          final completed = controller.completedTasksCount;
          final total = controller.totalTasksCount;
          final pctText = "${(pct * 100).toStringAsFixed(0)}%";
          final subText = total == 0
              ? 'Tidak ada tugas untuk hari ini.'
              : 'Kamu telah menyelesaikan $completed dari $total tugas hari ini. ${pct == 1.0 ? "Luar biasa!" : "Sedikit lagi!"}';
          
          return Row(
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
                      subText,
                      style: const TextStyle(
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
                      value: total == 0 ? 0.0 : pct,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFEFF4FF),
                      strokeCap: StrokeCap.round,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF065F46),
                      ),
                    ),
                  ),
                  Text(
                    total == 0 ? '0%' : pctText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final cats = controller.categories;
      final selectedId = controller.selectedCategoryId.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => controller.selectedCategoryId.value = '',
              child: _buildChip('Semua', selectedId.isEmpty),
            ),
            ...cats.map((cat) {
              final isSelected = selectedId == cat.id;
              return GestureDetector(
                onTap: () => controller.selectedCategoryId.value = cat.id ?? '',
                child: _buildChip(cat.name, isSelected),
              );
            }).toList(),
          ],
        ),
      );
    });
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
      child: Obx(() {
        final list = controller.filteredTasks;
        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'Tidak ada tugas untuk ditampilkan',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        return Column(
          children: list.map((task) {
            final cat = controller.categories.firstWhereOrNull((c) => c.id == task.categoryId);
            final catName = cat?.name ?? 'UMUM';
            final catColorHex = cat?.colorHex ?? '#FF6B7280';
            final catColor = _parseColor(catColorHex);

            return _buildTaskItem(
              task.title,
              task.description ?? 'Tidak ada deskripsi',
              catName.toUpperCase(),
              catColor.withOpacity(0.12),
              catColor,
              task.isCompleted,
              onToggle: () => controller.toggleTaskCompletion(task),
              onEdit: () {
                controller.prepareEditForm(task);
                Get.toNamed('/task/create');
              },
              priority: task.priority == 'high'
                  ? 'Prioritas Tinggi'
                  : (task.priority == 'medium' ? 'Prioritas Sedang' : 'Prioritas Rendah'),
              priorityColor: task.priority == 'high'
                  ? Colors.red
                  : (task.priority == 'medium' ? Colors.orange : Colors.blue),
              finishedAtText: (task.isCompleted && task.finishedAt != null) ? _formatFinishedAt(task.finishedAt!) : null,
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildTaskItem(
    String title,
    String subtitle,
    String category,
    Color categoryBg,
    Color categoryText,
    bool isDone, {
    required VoidCallback onToggle,
    required VoidCallback onEdit,
    String? priority,
    Color? priorityColor,
    String? finishedAtText,
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
          GestureDetector(
            onTap: onToggle,
            child: Container(
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (finishedAtText != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: Color(0xFF065F46),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selesai: $finishedAtText',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (priority != null && !isDone) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: priorityColor ?? Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          priority,
                          style: TextStyle(
                            fontSize: 12,
                            color: priorityColor ?? Colors.red,
                            fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

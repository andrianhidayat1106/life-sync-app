import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/task_model.dart';
import 'package:lifesync_app/app/data/providers/task_provider.dart';
import 'package:lifesync_app/app/data/models/category_model.dart';
import 'package:lifesync_app/app/data/providers/category_provider.dart';
import 'package:lifesync_app/core/services/cache_service.dart';

class TaskController extends GetxController {
  final TaskProvider _taskProvider = TaskProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();
  final CacheService _cacheService = Get.find<CacheService>();

  // State reaktif
  final tasks = <TaskModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;

  final selectedDate = DateTime.now().obs;
  final selectedCategoryId = ''.obs;
  final weekDays = <DateTime>[].obs;

  @override
  void onInit() {
    super.onInit();
    updateWeekDays(selectedDate.value);
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchCategories(),
        fetchTasks(),
      ]);
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Memuat Data',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    final fetched = await _categoryProvider.fetchAllCategories();
    // Filter kategori produktivitas (type = 'general')
    final generalCategories = fetched.where((cat) => cat.type == 'general').toList();
    categories.assignAll(generalCategories);
  }

  Future<void> fetchTasks() async {
    final fetched = await _taskProvider.fetchTasks();
    tasks.assignAll(fetched);
  }

  void updateWeekDays(DateTime date) {
    int currentWeekday = date.weekday; // 1 = Monday, 7 = Sunday
    DateTime monday = date.subtract(Duration(days: currentWeekday - 1));
    weekDays.value = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    updateWeekDays(date);
  }

  Future<void> selectDateFromPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF065F46), // Emerald Green
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF065F46)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectDate(picked);
    }
  }

  void resetToToday() {
    selectDate(DateTime.now());
  }

  // Helper date matching
  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isBeforeDate(DateTime a, DateTime b) {
    final dateA = DateTime(a.year, a.month, a.day);
    final dateB = DateTime(b.year, b.month, b.day);
    return dateA.isBefore(dateB);
  }

  // Daftar tugas yang relevan untuk tanggal terpilih (Hari ini + Backlog)
  List<TaskModel> get tasksForSelectedDate {
    final D = selectedDate.value;
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      final due = task.dueDate!;
      if (isSameDate(due, D)) {
        return true;
      }
      if (isBeforeDate(due, D)) {
        // Backlog / Overdue task:
        // Tampilkan jika belum selesai, ATAU jika selesai pada/setelah tanggal terpilih D
        return task.finishedAt == null || !isBeforeDate(task.finishedAt!, D);
      }
      return false;
    }).toList();
  }

  // Daftar tugas yang difilter dengan kategori terpilih
  List<TaskModel> get filteredTasks {
    final list = tasksForSelectedDate;
    if (selectedCategoryId.value.isEmpty) {
      return list;
    }
    return list.where((t) => t.categoryId == selectedCategoryId.value).toList();
  }

  // Kalkulasi Progres Harian (berdasarkan tasksForSelectedDate sebelum difilter kategori agar global)
  double get dailyProgressPercentage {
    final list = tasksForSelectedDate;
    if (list.isEmpty) return 0.0;

    final D = selectedDate.value;
    final completedCount = list.where((t) {
      return t.finishedAt != null && isSameDate(t.finishedAt!, D);
    }).length;

    return completedCount / list.length;
  }

  int get totalTasksCount => tasksForSelectedDate.length;

  int get completedTasksCount {
    final D = selectedDate.value;
    return tasksForSelectedDate.where((t) {
      return t.finishedAt != null && isSameDate(t.finishedAt!, D);
    }).length;
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final isCompleted = !task.isCompleted;
    final finishedAt = isCompleted ? DateTime.now() : null;
    final updatedTask = task.copyWith(
      isCompleted: isCompleted,
      finishedAt: finishedAt,
    );

    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final oldTask = tasks[index];
    tasks[index] = updatedTask;

    try {
      await _taskProvider.updateTask(updatedTask);
    } catch (e) {
      // Revert if error
      tasks[index] = oldTask;
      Get.rawSnackbar(
        title: 'Gagal Memperbarui Tugas',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String getUserFullName() {
    return _cacheService.read<String>('user_fullname') ?? 'Pengguna';
  }

  String getUserAvatarUrl() {
    return _cacheService.read<String>('user_profile_picture') ?? '';
  }
}

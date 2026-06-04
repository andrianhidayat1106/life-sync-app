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

  // State reaktif utama
  final tasks = <TaskModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;

  final selectedDate = DateTime.now().obs;
  final selectedCategoryId = ''.obs;
  final weekDays = <DateTime>[].obs;

  // Form states & controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final isEditMode = false.obs;
  final editTaskId = ''.obs;
  final selectedFormCategoryId = ''.obs;
  final selectedPriority = 'medium'.obs; // 'low', 'medium', 'high'
  final selectedFormDueDate = Rx<DateTime?>(null);

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
    final generalCategories = fetched.where((cat) => cat.type == 'general').toList();
    categories.assignAll(generalCategories);
  }

  Future<void> fetchTasks() async {
    final fetched = await _taskProvider.fetchTasks();
    tasks.assignAll(fetched);
  }

  void updateWeekDays(DateTime date) {
    int currentWeekday = date.weekday;
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
              primary: Color(0xFF065F46),
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

  // Form Management
  void prepareCreateForm() {
    isEditMode.value = false;
    editTaskId.value = '';
    titleController.clear();
    descriptionController.clear();
    
    if (categories.isNotEmpty) {
      selectedFormCategoryId.value = categories.first.id ?? '';
    } else {
      selectedFormCategoryId.value = '';
    }
    selectedPriority.value = 'medium';
    selectedFormDueDate.value = selectedDate.value;
  }

  void prepareEditForm(TaskModel task) {
    isEditMode.value = true;
    editTaskId.value = task.id ?? '';
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
    selectedFormCategoryId.value = task.categoryId ?? '';
    selectedPriority.value = task.priority;
    selectedFormDueDate.value = task.dueDate;
  }

  Future<void> selectFormDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedFormDueDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF065F46),
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
      selectedFormDueDate.value = picked;
    }
  }

  Future<void> saveTask() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.rawSnackbar(
        title: 'Validasi Gagal',
        message: 'Judul tugas tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedFormCategoryId.value.isEmpty) {
      Get.rawSnackbar(
        title: 'Validasi Gagal',
        message: 'Kategori tugas tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedFormDueDate.value == null) {
      Get.rawSnackbar(
        title: 'Validasi Gagal',
        message: 'Tenggat waktu harus diisi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Cari status penyelesaian jika dalam mode edit
      final existingTask = isEditMode.value
          ? tasks.firstWhereOrNull((t) => t.id == editTaskId.value)
          : null;
      final isCompletedVal = existingTask?.isCompleted ?? false;
      final finishedAtVal = existingTask?.finishedAt;

      final task = TaskModel(
        id: isEditMode.value ? editTaskId.value : null,
        title: title,
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        categoryId: selectedFormCategoryId.value,
        priority: selectedPriority.value,
        dueDate: selectedFormDueDate.value,
        isCompleted: isCompletedVal,
        finishedAt: finishedAtVal,
      );

      if (isEditMode.value) {
        final updated = await _taskProvider.updateTask(task);
        final idx = tasks.indexWhere((t) => t.id == editTaskId.value);
        if (idx != -1) {
          tasks[idx] = updated;
        }
      } else {
        final created = await _taskProvider.createTask(task);
        tasks.add(created);
      }

      await fetchTasks(); // Refresh tasks

      Get.back();
      Get.rawSnackbar(
        title: 'Sukses',
        message: isEditMode.value ? 'Tugas berhasil diperbarui' : 'Tugas berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Menyimpan Tugas',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTaskFromForm() async {
    if (editTaskId.value.isEmpty) return;
    try {
      isLoading.value = true;
      await _taskProvider.deleteTask(editTaskId.value);
      tasks.removeWhere((t) => t.id == editTaskId.value);
      Get.back();
      Get.rawSnackbar(
        title: 'Sukses',
        message: 'Tugas berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Menghapus Tugas',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Date Matching Helper
  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isBeforeDate(DateTime a, DateTime b) {
    final dateA = DateTime(a.year, a.month, a.day);
    final dateB = DateTime(b.year, b.month, b.day);
    return dateA.isBefore(dateB);
  }

  // Tasks Filter
  List<TaskModel> get tasksForSelectedDate {
    final D = selectedDate.value;
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      final due = task.dueDate!;
      if (isSameDate(due, D)) {
        return true;
      }
      if (isBeforeDate(due, D)) {
        return task.finishedAt == null || !isBeforeDate(task.finishedAt!, D);
      }
      return false;
    }).toList();
  }

  List<TaskModel> get filteredTasks {
    final list = tasksForSelectedDate;
    if (selectedCategoryId.value.isEmpty) {
      return list;
    }
    return list.where((t) => t.categoryId == selectedCategoryId.value).toList();
  }

  // Progress
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
      clearFinishedAt: !isCompleted,
    );

    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final oldTask = tasks[index];
    tasks[index] = updatedTask;

    try {
      await _taskProvider.updateTask(updatedTask);
    } catch (e) {
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

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

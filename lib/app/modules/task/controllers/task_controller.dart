import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/task_model.dart';
import 'package:lifesync_app/app/data/providers/task_provider.dart';
import 'package:lifesync_app/app/data/models/category_model.dart';
import 'package:lifesync_app/app/data/providers/category_provider.dart';
import 'package:lifesync_app/core/services/cache_service.dart';
import 'package:lifesync_app/core/utils/ui_helper.dart';
import 'package:lifesync_app/app/modules/profile/controllers/profile_controller.dart';

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
  final scrollController = ScrollController();

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

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(milliseconds: 300), () {
      scrollToSelectedDate();
    });
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchCategories(),
        fetchTasks(),
      ]);
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Memuat Data: ${e.toString().replaceAll('Exception: ', '')}');
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
    scrollToSelectedDate();
  }

  void scrollToSelectedDate() {
    if (!scrollController.hasClients) return;
    
    int index = -1;
    for (int i = 0; i < weekDays.length; i++) {
      if (isSameDate(weekDays[i], selectedDate.value)) {
        index = i;
        break;
      }
    }
    
    if (index != -1) {
      double itemWidth = 76.0; // 66 width + 10 margin
      double screenWidth = Get.width;
      double listPadding = 20.0; // padding horizontal listview
      
      double offset = (index * itemWidth) + listPadding - ((screenWidth - itemWidth) / 2);
      
      double maxScroll = scrollController.position.maxScrollExtent;
      double minScroll = scrollController.position.minScrollExtent;
      
      if (offset > maxScroll) offset = maxScroll;
      if (offset < minScroll) offset = minScroll;
      
      scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> selectDateFromPicker(BuildContext context) async {
    final DateTime? picked = await UIHelper.showCustomDatePicker(
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
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
    selectedPriority.value = 'medium';
    selectedFormDueDate.value = selectedDate.value;
    
    // Refresh categories from database so new/edited categories immediately appear
    fetchCategories().then((_) {
      if (categories.isNotEmpty) {
        if (selectedFormCategoryId.value.isEmpty || !categories.any((c) => c.id == selectedFormCategoryId.value)) {
          selectedFormCategoryId.value = categories.first.id ?? '';
        }
      } else {
        selectedFormCategoryId.value = '';
      }
    });
  }

  void prepareEditForm(TaskModel task) {
    isEditMode.value = true;
    editTaskId.value = task.id ?? '';
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
    selectedFormCategoryId.value = task.categoryId ?? '';
    selectedPriority.value = task.priority;
    selectedFormDueDate.value = task.dueDate;
    
    // Refresh categories from database so new/edited categories immediately appear
    fetchCategories();
  }

  Future<void> selectFormDate(BuildContext context) async {
    final DateTime? picked = await UIHelper.showCustomDatePicker(
      initialDate: selectedFormDueDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedFormDueDate.value = picked;
    }
  }

  Future<void> saveTask() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      UIHelper.showErrorSnackbar('Judul tugas tidak boleh kosong');
      return;
    }

    if (selectedFormCategoryId.value.isEmpty) {
      UIHelper.showErrorSnackbar('Kategori tugas tidak boleh kosong');
      return;
    }

    if (selectedFormDueDate.value == null) {
      UIHelper.showErrorSnackbar('Tenggat waktu harus diisi');
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
      UIHelper.showSuccessSnackbar(isEditMode.value ? 'Tugas berhasil diperbarui' : 'Tugas berhasil ditambahkan');
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Menyimpan Tugas: ${e.toString().replaceAll('Exception: ', '')}');
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
      UIHelper.showSuccessSnackbar('Tugas berhasil dihapus');
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Menghapus Tugas: ${e.toString().replaceAll('Exception: ', '')}');
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
      // 1. Tampilkan jika selesai pada tanggal terpilih D
      if (task.finishedAt != null && isSameDate(task.finishedAt!, D)) {
        return true;
      }

      if (task.dueDate == null) return false;
      final due = task.dueDate!;

      // 2. Tampilkan jika jatuh tempo pada tanggal terpilih D
      if (isSameDate(due, D)) {
        return true;
      }

      // 3. Tampilkan jika jatuh tempo sebelum D (backlog) dan belum selesai saat hari D dimulai
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

  // Progress and Completion Helpers
  bool isTaskCompletedOnDate(TaskModel task, DateTime targetDate) {
    if (!task.isCompleted || task.finishedAt == null) return false;
    final finishedDate = DateTime(task.finishedAt!.year, task.finishedAt!.month, task.finishedAt!.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return !finishedDate.isAfter(target);
  }

  double get dailyProgressPercentage {
    final list = tasksForSelectedDate;
    if (list.isEmpty) return 0.0;

    final D = selectedDate.value;
    final completedCount = list.where((t) => isTaskCompletedOnDate(t, D)).length;

    return completedCount / list.length;
  }

  int get totalTasksCount => tasksForSelectedDate.length;

  int get completedTasksCount {
    final D = selectedDate.value;
    return tasksForSelectedDate.where((t) => isTaskCompletedOnDate(t, D)).length;
  }

  Future<void> toggleTaskCompletion(TaskModel task, {DateTime? customDate}) async {
    final D = customDate ?? selectedDate.value;
    final currentlyCompleted = isTaskCompletedOnDate(task, D);
    
    final isCompleted = !currentlyCompleted;
    DateTime? finishedAt;
    if (isCompleted) {
      final now = DateTime.now();
      finishedAt = DateTime(D.year, D.month, D.day, now.hour, now.minute, now.second);
    }
    
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
      UIHelper.showErrorSnackbar('Gagal Memperbarui Tugas: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  String getUserFullName() {
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      if (pc.fullName.value.isNotEmpty) {
        return pc.fullName.value;
      }
    }
    return _cacheService.read<String>('user_fullname') ?? 'Pengguna';
  }

  String getUserAvatarUrl() {
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      if (pc.profileImagePath.value.isNotEmpty) {
        return pc.profileImagePath.value;
      }
    }
    return _cacheService.read<String>('user_profile_picture') ?? '';
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

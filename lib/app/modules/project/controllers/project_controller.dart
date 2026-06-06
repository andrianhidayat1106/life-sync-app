import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/project_model.dart';
import 'package:lifesync_app/app/data/providers/project_provider.dart';
import 'package:lifesync_app/app/data/models/task_model.dart';
import 'package:lifesync_app/app/data/providers/task_provider.dart';
import 'package:lifesync_app/app/data/models/category_model.dart';
import 'package:lifesync_app/app/data/providers/category_provider.dart';
import 'package:lifesync_app/core/services/cache_service.dart';

import 'package:lifesync_app/core/utils/ui_helper.dart';
import 'package:lifesync_app/app/modules/profile/controllers/profile_controller.dart';

class ProjectSubTask {
  final String? id;
  final TextEditingController controller;
  final RxBool isCompleted;

  ProjectSubTask({this.id, required String title, bool isCompleted = false})
      : controller = TextEditingController(text: title),
        isCompleted = isCompleted.obs;

  void dispose() {
    controller.dispose();
  }
}

class ProjectController extends GetxController {
  final ProjectProvider _projectProvider = ProjectProvider();
  final TaskProvider _taskProvider = TaskProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();
  final CacheService _cacheService = Get.find<CacheService>();

  final projects = <ProjectModel>[].obs;
  final tasks = <TaskModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;

  // Form State
  final isEditMode = false.obs;
  final editProjectId = RxnInt();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final selectedFormCategoryId = ''.obs;
  final selectedPriority = 'medium'.obs; // 'low', 'medium', 'high'
  final selectedFormDeadline = Rxn<DateTime>();

  final formSubTasks = <ProjectSubTask>[].obs;
  final deletedTaskIds = <String>[];

  @override
  void onInit() {
    print("[ProjectController] onInit called");
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    for (var subtask in formSubTasks) {
      subtask.dispose();
    }
    super.onClose();
  }

  Future<void> loadData() async {
    print("[ProjectController] loadData started");
    try {
      isLoading.value = true;
      
      print("[ProjectController] loadData: calling fetchTasks...");
      await fetchTasks();
      print("[ProjectController] loadData: fetchTasks finished");
      
      print("[ProjectController] loadData: calling fetchCategories...");
      await fetchCategories();
      print("[ProjectController] loadData: fetchCategories finished");

      print("[ProjectController] loadData: calling fetchProjects...");
      await fetchProjects();
      print("[ProjectController] loadData: fetchProjects finished");
      
      print("[ProjectController] loadData completed successfully. Projects count: ${projects.length}, Tasks count: ${tasks.length}, Categories count: ${categories.length}");
    } catch (e, stackTrace) {
      print("[ProjectController] ERROR in loadData: $e");
      print("[ProjectController] STACKTRACE: $stackTrace");
      UIHelper.showErrorSnackbar('Gagal Memuat Data: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProjects() async {
    print("[ProjectController] fetchProjects started");
    try {
      final fetched = await _projectProvider.fetchProjects();
      projects.assignAll(fetched);
      print("[ProjectController] fetchProjects success. Fetched ${fetched.length} projects.");
    } catch (e) {
      print("[ProjectController] ERROR in fetchProjects: $e");
      rethrow;
    }
  }

  Future<void> fetchTasks() async {
    print("[ProjectController] fetchTasks started");
    try {
      final fetched = await _taskProvider.fetchTasks();
      tasks.assignAll(fetched);
      print("[ProjectController] fetchTasks success. Fetched ${fetched.length} tasks.");
    } catch (e) {
      print("[ProjectController] ERROR in fetchTasks: $e");
      rethrow;
    }
  }

  Future<void> fetchCategories() async {
    print("[ProjectController] fetchCategories started");
    try {
      final fetched = await _categoryProvider.fetchAllCategories();
      final generalCategories = fetched.where((cat) => cat.type == 'general').toList();
      categories.assignAll(generalCategories);
      print("[ProjectController] fetchCategories success. Fetched ${generalCategories.length} general categories.");
    } catch (e) {
      print("[ProjectController] ERROR in fetchCategories: $e");
      rethrow;
    }
  }

  // Form helper actions
  void prepareCreateForm() {
    print("[ProjectController] prepareCreateForm called");
    isEditMode.value = false;
    editProjectId.value = null;
    nameController.clear();
    descriptionController.clear();
    
    if (categories.isNotEmpty) {
      selectedFormCategoryId.value = categories.first.id ?? '';
    } else {
      selectedFormCategoryId.value = '';
    }
    
    selectedPriority.value = 'medium';
    selectedFormDeadline.value = null;
    
    for (var subtask in formSubTasks) {
      subtask.dispose();
    }
    formSubTasks.clear();
    deletedTaskIds.clear();
  }

  void prepareEditForm(ProjectModel project) {
    print("[ProjectController] prepareEditForm called for project ID: ${project.id}");
    isEditMode.value = true;
    editProjectId.value = project.id;
    nameController.text = project.name;
    descriptionController.text = project.description ?? '';
    selectedFormCategoryId.value = project.categoryId ?? '';
    selectedPriority.value = project.priority;
    selectedFormDeadline.value = project.deadline;
    
    for (var subtask in formSubTasks) {
      subtask.dispose();
    }
    formSubTasks.clear();
    deletedTaskIds.clear();
    
    final projectTasks = tasks.where((t) => t.projectId == project.id.toString()).toList();
    for (var task in projectTasks) {
      formSubTasks.add(ProjectSubTask(
        id: task.id,
        title: task.title,
        isCompleted: task.isCompleted,
      ));
    }
    print("[ProjectController] Populated ${formSubTasks.length} subtasks for edit form.");
  }

  void addSubTaskField() {
    formSubTasks.add(ProjectSubTask(title: ''));
  }

  void removeSubTaskField(int index) {
    if (index >= 0 && index < formSubTasks.length) {
      final subtask = formSubTasks[index];
      if (subtask.id != null) {
        deletedTaskIds.add(subtask.id!);
      }
      subtask.dispose();
      formSubTasks.removeAt(index);
    }
  }

  Future<void> saveProject() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      UIHelper.showErrorSnackbar('Nama proyek tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;

      if (isEditMode.value) {
        final projectId = editProjectId.value;
        if (projectId == null) {
          throw Exception("Project ID tidak ditemukan");
        }

        final project = ProjectModel(
          id: projectId,
          name: name,
          description: descriptionController.text.trim(),
          categoryId: selectedFormCategoryId.value,
          priority: selectedPriority.value,
          deadline: selectedFormDeadline.value,
        );

        await _projectProvider.updateProject(project);

        // Delete removed tasks
        for (var taskId in deletedTaskIds) {
          await _taskProvider.deleteTask(taskId);
        }

        // Add / Update tasks
        for (var subtask in formSubTasks) {
          final subTitle = subtask.controller.text.trim();
          if (subTitle.isEmpty) continue;

          final task = TaskModel(
            id: subtask.id,
            projectId: projectId.toString(),
            categoryId: selectedFormCategoryId.value,
            title: subTitle,
            priority: selectedPriority.value,
            dueDate: selectedFormDeadline.value,
            isCompleted: subtask.isCompleted.value,
            finishedAt: subtask.isCompleted.value ? DateTime.now() : null,
          );

          if (subtask.id != null) {
            await _taskProvider.updateTask(task);
          } else {
            await _taskProvider.createTask(task);
          }
        }
      } else {
        // Create mode
        final project = ProjectModel(
          name: name,
          description: descriptionController.text.trim(),
          categoryId: selectedFormCategoryId.value,
          priority: selectedPriority.value,
          deadline: selectedFormDeadline.value,
        );

        final createdProject = await _projectProvider.createProject(project);
        final newProjectId = createdProject.id;
        if (newProjectId == null) {
          throw Exception("Gagal mendapatkan ID proyek yang baru dibuat");
        }

        for (var subtask in formSubTasks) {
          final subTitle = subtask.controller.text.trim();
          if (subTitle.isEmpty) continue;

          final task = TaskModel(
            projectId: newProjectId.toString(),
            categoryId: selectedFormCategoryId.value,
            title: subTitle,
            priority: selectedPriority.value,
            dueDate: selectedFormDeadline.value,
            isCompleted: subtask.isCompleted.value,
            finishedAt: subtask.isCompleted.value ? DateTime.now() : null,
          );

          await _taskProvider.createTask(task);
        }
      }

      await loadData();
      Get.back();
      UIHelper.showSuccessSnackbar('Proyek berhasil disimpan');
    } catch (e) {
      print("[ProjectController] ERROR in saveProject: $e");
      UIHelper.showErrorSnackbar('Gagal menyimpan proyek: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProjectFromForm() async {
    final projectId = editProjectId.value;
    if (projectId == null) return;

    try {
      isLoading.value = true;

      // Find all tasks associated with this project
      final projectTasks = tasks.where((t) => t.projectId == projectId.toString()).toList();
      for (var task in projectTasks) {
        if (task.id != null) {
          await _taskProvider.deleteTask(task.id!);
        }
      }

      // Delete the project
      await _projectProvider.deleteProject(projectId.toString());

      await loadData();
      Get.back();
      UIHelper.showSuccessSnackbar('Proyek berhasil dihapus');
    } catch (e) {
      print("[ProjectController] ERROR in deleteProjectFromForm: $e");
      UIHelper.showErrorSnackbar('Gagal menghapus proyek: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  // Dynamic statistics calculations per project
  int getTotalTasks(String projectId) {
    return tasks.where((t) => t.projectId == projectId).length;
  }

  int getCompletedTasks(String projectId) {
    return tasks.where((t) => t.projectId == projectId && t.isCompleted).length;
  }

  int getRemainingTasks(String projectId) {
    return getTotalTasks(projectId) - getCompletedTasks(projectId);
  }

  double getProgressPercentage(String projectId) {
    final total = getTotalTasks(projectId);
    if (total == 0) return 0.0;
    return getCompletedTasks(projectId) / total;
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
}

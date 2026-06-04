import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/project_model.dart';
import 'package:lifesync_app/app/data/providers/project_provider.dart';
import 'package:lifesync_app/app/data/models/task_model.dart';
import 'package:lifesync_app/app/data/providers/task_provider.dart';
import 'package:lifesync_app/app/data/models/category_model.dart';
import 'package:lifesync_app/app/data/providers/category_provider.dart';
import 'package:lifesync_app/core/services/cache_service.dart';

class ProjectController extends GetxController {
  final ProjectProvider _projectProvider = ProjectProvider();
  final TaskProvider _taskProvider = TaskProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();
  final CacheService _cacheService = Get.find<CacheService>();

  final projects = <ProjectModel>[].obs;
  final tasks = <TaskModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchProjects(),
        fetchTasks(),
        fetchCategories(),
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

  Future<void> fetchProjects() async {
    final fetched = await _projectProvider.fetchProjects();
    projects.assignAll(fetched);
  }

  Future<void> fetchTasks() async {
    final fetched = await _taskProvider.fetchTasks();
    tasks.assignAll(fetched);
  }

  Future<void> fetchCategories() async {
    final fetched = await _categoryProvider.fetchAllCategories();
    categories.assignAll(fetched);
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
    return _cacheService.read<String>('user_fullname') ?? 'Pengguna';
  }

  String getUserAvatarUrl() {
    return _cacheService.read<String>('user_profile_picture') ?? '';
  }
}

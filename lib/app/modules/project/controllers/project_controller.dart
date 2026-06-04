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
    print("[ProjectController] onInit called");
    super.onInit();
    loadData();
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
      categories.assignAll(fetched);
      print("[ProjectController] fetchCategories success. Fetched ${fetched.length} categories.");
    } catch (e) {
      print("[ProjectController] ERROR in fetchCategories: $e");
      rethrow;
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
    return _cacheService.read<String>('user_fullname') ?? 'Pengguna';
  }

  String getUserAvatarUrl() {
    return _cacheService.read<String>('user_profile_picture') ?? '';
  }
}

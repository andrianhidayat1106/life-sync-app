import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/app/data/models/project_model.dart';

class ProjectProvider {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  Future<List<ProjectModel>> fetchProjects() async {
    print("[ProjectProvider] fetchProjects: starting query");
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print("[ProjectProvider] fetchProjects: User is null");
        throw Exception("User tidak terautentikasi");
      }
      print("[ProjectProvider] fetchProjects: Authenticated user ID: ${user.id}");

      print("[ProjectProvider] fetchProjects: executing client.from('projects').select()");
      final response = await _client.from('projects').select();
      print("[ProjectProvider] fetchProjects: client response received. Type: ${response.runtimeType}");

      if (response == null) {
        print("[ProjectProvider] fetchProjects: response is null");
        return [];
      }

      final list = response as List;
      print("[ProjectProvider] fetchProjects: received list of length ${list.length}");

      // Filter by user_id in Dart
      final filtered = list.where((json) {
        final jsonMap = json as Map<String, dynamic>;
        return jsonMap['user_id']?.toString() == user.id;
      }).toList();
      print("[ProjectProvider] fetchProjects: filtered list count = ${filtered.length}");

      // Sort by created_at descending in Dart
      filtered.sort((a, b) {
        final mapA = a as Map<String, dynamic>;
        final mapB = b as Map<String, dynamic>;
        final timeAStr = mapA['created_at']?.toString();
        final timeBStr = mapB['created_at']?.toString();
        
        final timeA = timeAStr != null ? DateTime.parse(timeAStr) : DateTime(1970);
        final timeB = timeBStr != null ? DateTime.parse(timeBStr) : DateTime(1970);
        return timeB.compareTo(timeA); // Descending
      });
      print("[ProjectProvider] fetchProjects: sorting completed");

      final projectsList = filtered
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
      print("[ProjectProvider] fetchProjects: mapped to ProjectModel. Count: ${projectsList.length}");
      return projectsList;
    } catch (e, stack) {
      print("[ProjectProvider] fetchProjects: ERROR encountered: $e");
      print("[ProjectProvider] fetchProjects: STACKTRACE: $stack");
      rethrow;
    }
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = project.copyWith(userId: user.id).toJson();

    final response = await _client
        .from('projects')
        .insert(data)
        .select()
        .single();

    return ProjectModel.fromJson(response);
  }

  Future<void> deleteProject(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    await _client.from('projects').delete().eq('id', int.tryParse(id) ?? id);
  }
}

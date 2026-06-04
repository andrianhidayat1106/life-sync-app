import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/app/data/models/project_model.dart';

class ProjectProvider {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  Future<List<ProjectModel>> fetchProjects() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final response = await _client
        .from('projects')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
        .toList();
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

    await _client.from('projects').delete().eq('id', id);
  }
}

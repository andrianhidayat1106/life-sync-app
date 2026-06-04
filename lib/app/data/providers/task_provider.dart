import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/app/data/models/task_model.dart';

class TaskProvider {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  Future<List<TaskModel>> fetchTasks() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', user.id)
        .order('due_date', ascending: true)
        .timeout(const Duration(seconds: 10));

    return (response as List)
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = task.copyWith(userId: user.id).toJson();

    final response = await _client
        .from('tasks')
        .insert(data)
        .select()
        .single();

    return TaskModel.fromJson(response);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = task.toJson();

    final response = await _client
        .from('tasks')
        .update(data)
        .eq('id', task.id!)
        .select()
        .single();

    return TaskModel.fromJson(response);
  }

  Future<void> deleteTask(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    await _client.from('tasks').delete().eq('id', id);
  }
}

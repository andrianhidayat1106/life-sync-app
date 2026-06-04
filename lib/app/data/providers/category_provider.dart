import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/app/data/models/category_model.dart';

class CategoryProvider {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  Future<List<CategoryModel>> fetchAllCategories() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final response = await _client
        .from('categories')
        .select()
        .eq('user_id', user.id)
        .order('name', ascending: true);

    final list = (response as List)
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return list;
  }

  Future<List<CategoryModel>> fetchFinanceCategories() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final response = await _client
        .from('categories')
        .select()
        .eq('user_id', user.id)
        .eq('type', 'finance');

    final list = (response as List)
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return list;
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = category.copyWith(userId: user.id).toJson();

    final response = await _client
        .from('categories')
        .insert(data)
        .select()
        .single();

    return CategoryModel.fromJson(response);
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = category.toJson();

    final response = await _client
        .from('categories')
        .update(data)
        .eq('id', int.tryParse(category.id!) ?? category.id!)
        .select()
        .single();

    return CategoryModel.fromJson(response);
  }

  Future<void> deleteCategory(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    await _client.from('categories').delete().eq('id', int.tryParse(id) ?? id);
  }
}

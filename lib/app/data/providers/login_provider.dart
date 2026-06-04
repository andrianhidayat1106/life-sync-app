import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/app/data/models/user_model.dart';

class LoginProvider {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  Future<UserModel> login(UserModel user) async {
    if (user.password == null || user.password!.isEmpty) {
      throw Exception("Password tidak boleh kosong");
    }

    final response = await _client.auth.signInWithPassword(
      email: user.email,
      password: user.password!,
    );

    final sbUser = response.user;
    if (sbUser == null) {
      throw Exception("Login gagal, data user tidak ditemukan");
    }

    return UserModel(
      id: sbUser.id,
      email: sbUser.email ?? user.email,
      fullName: sbUser.userMetadata?['full_name'] as String? ?? sbUser.userMetadata?['fullName'] as String?,
    );
  }
}

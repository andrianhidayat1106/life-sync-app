import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/app/data/models/notification_model.dart';

class NotificationProvider {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  Future<List<NotificationModel>> fetchNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<NotificationModel> createNotification(NotificationModel notif) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = notif.copyWith(userId: user.id).toJson();

    final response = await _client
        .from('notifications')
        .insert(data)
        .select()
        .single();

    return NotificationModel.fromJson(response);
  }

  Future<NotificationModel> updateNotification(NotificationModel notif) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = notif.toJson();

    final response = await _client
        .from('notifications')
        .update(data)
        .eq('id', notif.id!)
        .select()
        .single();

    return NotificationModel.fromJson(response);
  }

  Future<void> markAllAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    await _client
        .from('notifications')
        .update({'is_unread': false})
        .eq('user_id', user.id);
  }
}

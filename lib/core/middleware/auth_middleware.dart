import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/routes/app_pages.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// Mencegah user yang BELUM login masuk ke halaman utama aplikasi
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      debugPrint("AuthMiddleware: Pengguna tidak terotentikasi. Mengalihkan ke LOGIN.");
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

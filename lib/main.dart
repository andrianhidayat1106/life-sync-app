import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lifesync_app/core/theme/app_theme.dart';
import 'package:lifesync_app/core/services/cache_service.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';

import 'package:lifesync_app/core/services/notification_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Cache Service (Lokal)
  await Get.putAsync(() => CacheService().init());

  // Inisialisasi Supabase Service (Cloud) dengan toleransi kegagalan koneksi

  try {
    await Get.putAsync(() => SupabaseService().init());
  } catch (e) {
    debugPrint("Gagal menginisialisasi Supabase/Auth/Profile Service: $e");
  }

  try {
    final ns = NotificationService();
    await ns.init();
    await ns.requestPermissions();
  } catch (e) {
    debugPrint("Gagal menginisialisasi NotificationService: $e");
  }

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
    ),
  );
}

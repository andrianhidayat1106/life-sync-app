import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

class SupabaseService extends GetxService {
  // Getter konvensional agar pemanggilan client di controller lebih singkat
  SupabaseClient get client => Supabase.instance.client;

  // Fungsi inisialisasi yang dijalankan saat aplikasi pertama kali dibuka

  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: SupabaseConstants.url,
      anonKey: SupabaseConstants.anonKey,
    );
    return this;
  }
}

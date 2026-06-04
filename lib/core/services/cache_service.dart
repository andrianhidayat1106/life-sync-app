import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CacheService extends GetxService {
  late final GetStorage _box;

  Future<CacheService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Menyimpan data ke cache
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  // Mengambil data dari cache
  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  // Menghapus data dari cache berdasarkan key
  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  // Membersihkan semua data cache
  Future<void> clear() async {
    await _box.erase();
  }
}

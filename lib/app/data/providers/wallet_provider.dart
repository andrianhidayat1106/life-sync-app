import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/app/data/models/wallet_model.dart';

class WalletProvider {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  Future<List<WalletModel>> fetchWallets() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final response = await _client
        .from('wallets')
        .select()
        .eq('user_id', user.id)
        .order('id', ascending: true);

    return (response as List)
        .map((json) => WalletModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<WalletModel> createWallet(WalletModel wallet) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    // Set user_id dari sesi saat ini secara otomatis
    final walletData = wallet.copyWith(userId: user.id).toJson();

    final response = await _client
        .from('wallets')
        .insert(walletData)
        .select()
        .single();

    return WalletModel.fromJson(response);
  }

  Future<WalletModel> updateWallet(WalletModel wallet) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = wallet.toJson();

    final response = await _client
        .from('wallets')
        .update(data)
        .eq('id', wallet.id!)
        .select()
        .single();

    return WalletModel.fromJson(response);
  }

  Future<void> deleteWallet(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    await _client.from('wallets').delete().eq('id', int.tryParse(id) ?? id);
  }
}

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifesync_app/core/services/supabase_service.dart';
import 'package:lifesync_app/app/data/models/transaction_model.dart';

class TransactionProvider {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  Future<List<TransactionModel>> fetchTransactions() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final response = await _client
        .from('transactions')
        .select('*, categories:category_id(*), wallets:wallet_id(*)')
        .eq('user_id', user.id)
        .order('transaction_date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionModel> createTransaction(TransactionModel tx) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = tx.copyWith(userId: user.id).toJson();

    final response = await _client
        .from('transactions')
        .insert(data)
        .select('*, categories:category_id(*), wallets:wallet_id(*)')
        .single();

    return TransactionModel.fromJson(response);
  }

  Future<TransactionModel> updateTransaction(TransactionModel tx) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    final data = tx.toJson();

    final response = await _client
        .from('transactions')
        .update(data)
        .eq('id', int.tryParse(tx.id!) ?? tx.id!)
        .select('*, categories:category_id(*), wallets:wallet_id(*)')
        .single();

    return TransactionModel.fromJson(response);
  }

  Future<void> deleteTransaction(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("User tidak terautentikasi");
    }

    await _client
        .from('transactions')
        .delete()
        .eq('id', int.tryParse(id) ?? id);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/wallet_model.dart';
import 'package:lifesync_app/app/data/providers/wallet_provider.dart';
import 'package:lifesync_app/app/data/models/transaction_model.dart';
import 'package:lifesync_app/app/data/providers/transaction_provider.dart';

class WalletController extends GetxController {
  final WalletProvider _walletProvider = WalletProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();

  // State reaktif
  final wallets = <WalletModel>[].obs;
  final transactions = <TransactionModel>[].obs;
  final isLoading = false.obs;
  final currentCarouselIndex = 0.obs;
  final selectedFilter = 'Semua'.obs;
  final searchQuery = ''.obs;

  // Total bulanan
  final totalIncomeThisMonth = 0.0.obs;
  final totalOutcomeThisMonth = 0.0.obs;

  // Controllers untuk Form Dompet Baru
  final walletNameController = TextEditingController();
  final initialBalanceController = TextEditingController();
  final selectedColorHex = '1E3A8A'.obs; // Default biru BCA

  final previewName = 'NAMA DOMPET'.obs;
  final previewBalance = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
    
    walletNameController.addListener(() {
      previewName.value = walletNameController.text.isEmpty
          ? 'NAMA DOMPET'
          : walletNameController.text.toUpperCase();
    });
    initialBalanceController.addListener(() {
      final val = double.tryParse(initialBalanceController.text) ?? 0.0;
      previewBalance.value = val.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    });
  }

  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      // Muat data dompet dan transaksi secara paralel
      await Future.wait([
        loadWalletsSilent(),
        loadTransactionsSilent(),
      ]);
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Memuat Data',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWalletsSilent() async {
    final fetched = await _walletProvider.fetchWallets();
    wallets.assignAll(fetched);
  }

  Future<void> loadTransactionsSilent() async {
    final fetched = await _transactionProvider.fetchTransactions();
    transactions.assignAll(fetched);
    calculateMonthlyTotals();
  }

  Future<void> loadWallets() async {
    try {
      isLoading.value = true;
      await loadWalletsSilent();
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Memuat Dompet',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      await loadTransactionsSilent();
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Memuat Transaksi',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void calculateMonthlyTotals() {
    final now = DateTime.now();
    double income = 0.0;
    double outcome = 0.0;

    for (var tx in transactions) {
      if (tx.transactionDate.year == now.year &&
          tx.transactionDate.month == now.month) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else if (tx.type == 'outcome') {
          outcome += tx.amount;
        }
      }
    }

    totalIncomeThisMonth.value = income;
    totalOutcomeThisMonth.value = outcome;
  }

  Future<void> deleteTransaction(String id) async {
    try {
      isLoading.value = true;
      await _transactionProvider.deleteTransaction(id);
      await refreshData();
      Get.rawSnackbar(
        title: 'Sukses',
        message: 'Transaksi berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Menghapus Transaksi',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNewWallet() async {
    final name = walletNameController.text.trim();
    final balanceText = initialBalanceController.text.trim();

    if (name.isEmpty) {
      Get.rawSnackbar(
        title: 'Validasi Gagal',
        message: 'Nama dompet tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final balance = double.tryParse(balanceText) ?? 0.0;

    try {
      isLoading.value = true;

      final newWallet = WalletModel(
        name: name,
        type: 'Personal', // Default type
        icon: 'wallet',    // Default icon
        colorHex: selectedColorHex.value,
        balance: balance,
      );

      await _walletProvider.createWallet(newWallet);

      // Reset form
      walletNameController.clear();
      initialBalanceController.clear();
      selectedColorHex.value = '1E3A8A';
      previewName.value = 'NAMA DOMPET';
      previewBalance.value = '0';

      // Reload data & kembali ke halaman sebelumnya
      await refreshData();
      Get.back();

      Get.rawSnackbar(
        title: 'Sukses',
        message: 'Dompet baru berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Menyimpan Dompet',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectColor(String hex) {
    selectedColorHex.value = hex;
  }

  @override
  void onClose() {
    walletNameController.dispose();
    initialBalanceController.dispose();
    super.onClose();
  }
}

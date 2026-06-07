import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/wallet_model.dart';
import 'package:lifesync_app/app/data/providers/wallet_provider.dart';
import 'package:lifesync_app/app/data/models/transaction_model.dart';
import 'package:lifesync_app/app/data/providers/transaction_provider.dart';
import 'package:lifesync_app/app/data/models/category_model.dart';
import 'package:lifesync_app/app/data/providers/category_provider.dart';
import 'package:lifesync_app/core/utils/ui_helper.dart';
import 'package:lifesync_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:lifesync_app/core/services/cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletController extends GetxController {
  final WalletProvider _walletProvider = WalletProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();

  // State reaktif
  final wallets = <WalletModel>[].obs;
  final transactions = <TransactionModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final currentCarouselIndex = 0.obs;
  final selectedFilter = 'Semua'.obs;
  final searchQuery = ''.obs;

  // Filter for TransactionView
  final selectedDateFilter = 'Semua'.obs; // Semua, Hari Ini, 1 Minggu, Bulan Ini, Pilih Tanggal
  final customDateFilter = Rxn<DateTime>();
  final selectedCategoryFilter = ''.obs; // empty = all

  final isEditMode = false.obs;
  final editWalletId = RxnInt();

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
      // Muat data dompet, transaksi, dan kategori secara paralel
      await Future.wait([
        loadWalletsSilent(),
        loadTransactionsSilent(),
        loadCategoriesSilent(),
      ]);
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Memuat Data: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategoriesSilent() async {
    try {
      final categoryProvider = CategoryProvider();
      final fetched = await categoryProvider.fetchFinanceCategories();
      categories.assignAll(fetched);
    } catch (_) {
      // silent fail — categories are optional for filter
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
      UIHelper.showErrorSnackbar('Gagal Memuat Dompet: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      await loadTransactionsSilent();
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Memuat Transaksi: ${e.toString().replaceAll('Exception: ', '')}');
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

      TransactionModel? tx;
      for (var t in transactions) {
        if (t.id == id) {
          tx = t;
          break;
        }
      }

      if (tx != null) {
        WalletModel? wallet;
        for (var w in wallets) {
          if (w.id.toString() == tx.walletId) {
            wallet = w;
            break;
          }
        }
        if (wallet != null) {
          double newBalance = wallet.balance ?? 0.0;
          if (tx.type == 'income') {
            newBalance -= tx.amount;
          } else {
            newBalance += tx.amount;
          }
          await _walletProvider.updateWallet(wallet.copyWith(balance: newBalance));
        }
      }

      await _transactionProvider.deleteTransaction(id);
      await refreshData();
      UIHelper.showSuccessSnackbar('Transaksi berhasil dihapus');
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Menghapus Transaksi: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  void prepareEditForm(WalletModel wallet) {
    isEditMode.value = true;
    editWalletId.value = wallet.id;
    walletNameController.text = wallet.name ?? '';
    initialBalanceController.text = wallet.balance?.toStringAsFixed(0) ?? '0';
    selectedColorHex.value = wallet.colorHex ?? '1E3A8A';
    previewName.value = (wallet.name ?? 'NAMA DOMPET').toUpperCase();
    previewBalance.value = wallet.balance?.toStringAsFixed(0) ?? '0';
  }

  void prepareCreateForm() {
    isEditMode.value = false;
    editWalletId.value = null;
    walletNameController.clear();
    initialBalanceController.clear();
    selectedColorHex.value = '1E3A8A';
    previewName.value = 'NAMA DOMPET';
    previewBalance.value = '0';
  }

  Future<void> saveWallet() async {
    final name = walletNameController.text.trim();
    final balanceText = initialBalanceController.text.trim();

    if (name.isEmpty) {
      UIHelper.showErrorSnackbar('Nama dompet tidak boleh kosong');
      return;
    }

    final balance = double.tryParse(balanceText) ?? 0.0;

    try {
      isLoading.value = true;

      if (isEditMode.value) {
        if (editWalletId.value == null) return;
        final existingWallet = wallets.firstWhereOrNull((w) => w.id == editWalletId.value);
        if (existingWallet == null) return;
        
        final updatedWallet = existingWallet.copyWith(
          name: name,
          colorHex: selectedColorHex.value,
          balance: balance,
        );
        await _walletProvider.updateWallet(updatedWallet);
      } else {
        final newWallet = WalletModel(
          name: name,
          type: 'Personal', // Default type
          icon: 'wallet',    // Default icon
          colorHex: selectedColorHex.value,
          balance: balance,
        );
        await _walletProvider.createWallet(newWallet);
      }

      final wasEditMode = isEditMode.value;

      // Reset form
      walletNameController.clear();
      initialBalanceController.clear();
      selectedColorHex.value = '1E3A8A';
      previewName.value = 'NAMA DOMPET';
      previewBalance.value = '0';
      isEditMode.value = false;
      editWalletId.value = null;

      // Reload data & kembali ke halaman sebelumnya
      await refreshData();
      Get.back();

      UIHelper.showSuccessSnackbar(wasEditMode ? 'Dompet berhasil diperbarui' : 'Dompet baru berhasil ditambahkan');
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Menyimpan Dompet: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNewWallet() async {
    await saveWallet();
  }

  Future<void> deleteWallet(int id) async {
    try {
      isLoading.value = true;
      await _walletProvider.deleteWallet(id.toString());
      
      // Reset form
      walletNameController.clear();
      initialBalanceController.clear();
      selectedColorHex.value = '1E3A8A';
      previewName.value = 'NAMA DOMPET';
      previewBalance.value = '0';
      isEditMode.value = false;
      editWalletId.value = null;

      await refreshData();
      Get.back();
      UIHelper.showSuccessSnackbar('Dompet berhasil dihapus');
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Menghapus Dompet: ${e.toString().replaceAll('Exception: ', '')}');
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

  String getUserFullName() {
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      if (pc.fullName.value.isNotEmpty) {
        return pc.fullName.value;
      }
    }
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.user.userMetadata != null) {
      final fullName = session.user.userMetadata!['full_name'];
      if (fullName != null && fullName.toString().isNotEmpty) {
        return fullName.toString();
      }
    }
    
    return Get.find<CacheService>().read<String>('user_fullname') ?? 'Pengguna';
  }

  String getUserAvatarUrl() {
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      if (pc.profileImagePath.value.isNotEmpty) {
        return pc.profileImagePath.value;
      }
    }
    return Get.find<CacheService>().read<String>('user_profile_picture') ?? '';
  }
}

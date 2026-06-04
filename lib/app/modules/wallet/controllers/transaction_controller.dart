import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/transaction_model.dart';
import 'package:lifesync_app/app/data/providers/transaction_provider.dart';
import 'package:lifesync_app/app/data/models/category_model.dart';
import 'package:lifesync_app/app/data/providers/category_provider.dart';
import 'package:lifesync_app/app/data/models/wallet_model.dart';
import 'package:lifesync_app/app/data/providers/wallet_provider.dart';
import 'package:lifesync_app/app/modules/wallet/controllers/wallet_controller.dart';

class TransactionController extends GetxController {
  final CategoryProvider _categoryProvider = CategoryProvider();
  final WalletProvider _walletProvider = WalletProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();

  // Form states
  final isIncome = true.obs;
  final amountController = TextEditingController();
  final selectedCategoryId = ''.obs;
  final selectedWalletId = ''.obs;
  final selectedDate = DateTime.now().obs;
  final notesController = TextEditingController();

  // Lists
  final categories = <CategoryModel>[].obs;
  final wallets = <WalletModel>[].obs;
  final isLoading = false.obs;

  // Edit states
  TransactionModel? editTransaction;
  final isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil arguments untuk edit mode jika ada
    final tx = Get.arguments as TransactionModel?;
    if (tx != null) {
      editTransaction = tx;
      isEditMode.value = true;
      isIncome.value = tx.type == 'income';
      amountController.text = tx.amount.toStringAsFixed(0);
      selectedCategoryId.value = tx.categoryId;
      selectedWalletId.value = tx.walletId;
      selectedDate.value = tx.transactionDate;
      notesController.text = tx.notes ?? '';
    }

    loadInitialData();

    // Reset selected category id jika pilihan income/outcome berubah
    ever(isIncome, (_) {
      final filtered = filteredCategories;
      if (filtered.isNotEmpty) {
        selectedCategoryId.value = filtered.first.id ?? '';
      } else {
        selectedCategoryId.value = '';
      }
    });
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchCategoriesSilent(),
        fetchWalletsSilent(),
      ]);
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Memuat Form',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategoriesSilent() async {
    final fetched = await _categoryProvider.fetchFinanceCategories();
    categories.assignAll(fetched);
    if (selectedCategoryId.value.isEmpty && filteredCategories.isNotEmpty) {
      selectedCategoryId.value = filteredCategories.first.id ?? '';
    }
  }

  Future<void> fetchWalletsSilent() async {
    final fetched = await _walletProvider.fetchWallets();
    wallets.assignAll(fetched);
    if (selectedWalletId.value.isEmpty && wallets.isNotEmpty) {
      selectedWalletId.value = wallets.first.id.toString();
    }
  }

  List<CategoryModel> get filteredCategories {
    final targetType = isIncome.value ? 'income' : 'outcome';
    return categories.where((c) => c.description == targetType).toList();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  Future<void> saveTransaction() async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      Get.rawSnackbar(
        title: 'Validasi Gagal',
        message: 'Nominal transaksi tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) {
      Get.rawSnackbar(
        title: 'Validasi Gagal',
        message: 'Nominal harus lebih dari 0',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedCategoryId.value.isEmpty) {
      Get.rawSnackbar(
        title: 'Validasi Gagal',
        message: 'Harap pilih kategori transaksi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedWalletId.value.isEmpty) {
      Get.rawSnackbar(
        title: 'Validasi Gagal',
        message: 'Harap pilih dompet transaksi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final transaction = TransactionModel(
        id: isEditMode.value ? editTransaction?.id : null,
        walletId: selectedWalletId.value,
        categoryId: selectedCategoryId.value,
        amount: amount,
        type: isIncome.value ? 'income' : 'outcome',
        transactionDate: selectedDate.value,
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      );

      if (isEditMode.value) {
        await _transactionProvider.updateTransaction(transaction);
      } else {
        await _transactionProvider.createTransaction(transaction);
      }

      // Refresh controller utama
      final walletController = Get.find<WalletController>();
      await walletController.refreshData();

      Get.back();
      Get.rawSnackbar(
        title: 'Sukses',
        message: isEditMode.value ? 'Transaksi berhasil diperbarui' : 'Transaksi berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.rawSnackbar(
        title: 'Gagal Menyimpan',
        message: e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}

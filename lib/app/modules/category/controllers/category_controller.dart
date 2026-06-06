import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifesync_app/app/data/models/category_model.dart';
import 'package:lifesync_app/app/data/providers/category_provider.dart';
import 'package:lifesync_app/core/utils/ui_helper.dart';

class CategoryController extends GetxController {
  final CategoryProvider _categoryProvider = CategoryProvider();

  // State reaktif
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs; // 0 = Finance, 1 = Productivity

  // Form states
  final isEditMode = false.obs;
  final editCategoryId = ''.obs;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedType = 'finance'.obs; // 'finance' atau 'general'
  final selectedTypeIndex = 0.obs;
  final selectedIcon = 'account_balance'.obs;
  final selectedColorHex = '065F46'.obs; // Default Emerald

  final previewName = 'Nama Kategori'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();

    // Sync type index
    ever(selectedType, (type) {
      selectedTypeIndex.value = type == 'finance' ? 0 : 1;
    });

    nameController.addListener(() {
      previewName.value = nameController.text.isEmpty
          ? 'Nama Kategori'
          : nameController.text;
    });
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final fetched = await _categoryProvider.fetchAllCategories();
      categories.assignAll(fetched);
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Memuat Kategori: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  void prepareCreateForm() {
    isEditMode.value = false;
    editCategoryId.value = '';
    nameController.clear();
    descriptionController.clear();
    selectedType.value = 'finance';
    selectedIcon.value = 'account_balance';
    selectedColorHex.value = '065F46';
    previewName.value = 'Nama Kategori';
  }

  void prepareEditForm(CategoryModel category) {
    isEditMode.value = true;
    editCategoryId.value = category.id ?? '';
    nameController.text = category.name;
    descriptionController.text = category.description ?? '';
    selectedType.value = category.type == 'finance' ? 'finance' : 'general';
    selectedIcon.value = category.icon;
    selectedColorHex.value = category.colorHex
        .replaceAll('#FF', '')
        .replaceAll('#', '');
    previewName.value = category.name;
  }

  Future<void> saveCategory() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      UIHelper.showErrorSnackbar('Nama kategori tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;

      final category = CategoryModel(
        id: isEditMode.value ? editCategoryId.value : null,
        name: name,
        type: selectedType.value,
        icon: selectedIcon.value,
        colorHex: '#FF${selectedColorHex.value}',
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );

      if (isEditMode.value) {
        await _categoryProvider.updateCategory(category);
      } else {
        await _categoryProvider.createCategory(category);
      }

      await loadCategories();
      Get.back();

      UIHelper.showSuccessSnackbar(isEditMode.value ? 'Kategori berhasil diperbarui' : 'Kategori berhasil ditambahkan');
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Menyimpan Kategori: ${e.toString().replaceAll('Exception: ', '')}');

      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      await _categoryProvider.deleteCategory(id);
      await loadCategories();

      Get.back(); // Kembali dari form page

      UIHelper.showSuccessSnackbar('Kategori berhasil dihapus');
    } catch (e) {
      UIHelper.showErrorSnackbar('Gagal Menghapus Kategori: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

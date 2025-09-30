import 'dart:io';

import 'package:caferesto/data/repositories/authentication/authentication_repository.dart';
import 'package:caferesto/data/repositories/product/product_repository.dart';
import 'package:caferesto/features/shop/models/category_model.dart';
import 'package:caferesto/features/shop/models/product_model.dart';
import 'package:caferesto/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/categories/category_repository.dart';
import '../../../utils/constants/image_strings.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final parentIdController = TextEditingController();
  final isFeatured = false.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final pickedImage = Rx<File?>(null);

  /// Variables
  final isLoading = false.obs;
  final _categoryRepository = Get.put(CategoryRepository());
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;

  /// image depuis gallery
  Future<void> pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
    }
  }

  /// Réinitiliser formulaire
  void clearForm() {
    nameController.clear();
    parentIdController.clear();
    isFeatured.value = false;
    pickedImage.value = null;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  /// Charger tout les categories
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final categories = await _categoryRepository.getAllCategories();
      // Mettre à jour liste de categories
      allCategories.assignAll(categories);

      // Filtrer Categories en vedette
      featuredCategories.assignAll(
          categories.where((category) => category.isFeatured).take(8).toList());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Erreur!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Charger les catégories sélectionnés

  Future<List<CategoryModel>> getSubCategories(String categoryId) async {
    try {
      // Charger category depuis repository
      final subCategories =
          await _categoryRepository.getSubCategories(categoryId);
      return subCategories;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
      return [];
    }
  }

  /// Charger les produits de catégorie ou sous_catégorie
  Future<List<ProductModel>> getCategoryProducts(
      {required String categoryId, int limit = 4}) async {
    try {
      // Charger produits pour un category id
      final products = await ProductRepository.instance
          .getProductsForCategory(categoryId: categoryId, limit: limit);
      return products;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
      return [];
    }
  }

  Future<void> addCategory() async {
    if (!formKey.currentState!.validate()) return;

    final userRole =
        AuthenticationRepository.instance.authUser?.userMetadata?['role'];
    print("role ${userRole}");

    if (userRole != 'Gérant' && userRole != 'Admin') {
      throw "Vous n'avez pas la permission d'ajouter une catégorie.";
    }

    try {
      isLoading.value = true;

      String imageUrl = TImages.coffee;
      if (pickedImage.value != null) {
        imageUrl = pickedImage.value!.path;
      }

      final newCategory = CategoryModel(
        id: '',
        name: nameController.text.trim(),
        image: imageUrl,
        parentId: parentIdController.text.trim(),
        isFeatured: isFeatured.value,
      );

      await CategoryRepository.instance.addCategory(newCategory);
      // Rafrâichir les catégories après ajout
      await fetchCategories();

      clearForm();
      Get.back();
      TLoaders.successSnackBar(
          title: 'Succès', message: 'Catégorie ajoutée avec succès');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

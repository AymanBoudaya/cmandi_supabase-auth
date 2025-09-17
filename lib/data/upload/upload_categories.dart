import '../../features/shop/models/category_model.dart';
import '../../utils/constants/image_strings.dart';

class UploadCategories {
  UploadCategories._();

  /// Dummy categories list
  static final List<CategoryModel> dummyCategories = [
    CategoryModel(
      name: 'Café',
      image: TImages.coffee,
      isFeatured: true,
      parentId: '',
    ),
    CategoryModel(
      name: 'Mlewi',
      image: TImages.mlewiCategory,
      isFeatured: true,
      parentId: '',
    ),
    CategoryModel(
      name: 'Boissons',
      image: TImages.boissonsCategory,
      isFeatured: true,
      parentId: '',
    ),
    CategoryModel(
      name: 'Petit Déjeuner',
      image: TImages.petitdej,
      isFeatured: true,
      parentId: '',
    ),
    CategoryModel(
      name: 'Glaces',
      image: TImages.clothIcon,
      parentId: '1',
      isFeatured: true,
    ),
  ];
}

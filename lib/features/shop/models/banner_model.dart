import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  String id;
  String name;
  String image;
  bool? isFeatured;
  int? productsCount;

  BannerModel({
    required this.id,
    required this.name,
    required this.image,
    this.isFeatured,
    this.productsCount,
  });

  // Empty Helper Function
  static BannerModel empty() {
    return BannerModel(
      id: '',
      image: '',
      name: '',
    );
  }

  /// Conver model to JSON structure so that you can store data in Firestore
  toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'ProductsCount': productsCount,
      'IsFeatured': isFeatured,
    };
  }

  /// Map from firebase to user model
  factory BannerModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) {
      return BannerModel.empty();
    }
    return BannerModel(
      id: data['Id'] ?? '',
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      isFeatured: data['IsFeatured'] as bool? ?? false,
      productsCount: data['ProductsCount'] as int?,
    );
  }

  /// Map from firebase snapshot to user model
  factory BannerModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map Json record to the Model
      return BannerModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        productsCount: data['ProductsCount'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
      );
    } else {
      return BannerModel.empty();
    }
  }
}
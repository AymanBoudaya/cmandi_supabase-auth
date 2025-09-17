class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;

  CategoryModel({
    this.id = '',
    required this.name,
    required this.image,
    required this.isFeatured,
    this.parentId = '',
  });

  /// Empty helper function
  static CategoryModel empty() {
    return CategoryModel(
      id: '',
      image: '',
      name: '',
      isFeatured: false,
      parentId: '',
    );
  }

  /// Convert CategoryModel to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson({bool includeId = false}) {
    final data = {
      'name': name.trim(),
      'image': image,
      'parentId': parentId,
      'isFeatured': isFeatured,
    };
    if (includeId) data['id'] = id;
    return data;
  }

  /// More generic: works for Firebase OR untyped JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      return CategoryModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        image: json['image'] ?? '',
        parentId: json['parentId'] ?? '',
        isFeatured: json['isFeatured'] ?? false,
      );
    } catch (e) {
      return CategoryModel.empty();
    }
  }

  /// Supabase-specific: typed Postgres row → Dart object
  factory CategoryModel.fromSupabaseRow(Map<String, dynamic> row) {
    return CategoryModel(
      id: row['id']?.toString() ?? '', // works for uuid or int
      name: row['name'] ?? '',
      image: row['image'] ?? '',
      parentId: row['parentId']?.toString() ?? '',
      isFeatured: row['isFeatured'] ?? false, // already a bool
    );
  }

  /// Clone with updated fields (immutable style updates)
  CategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    String? parentId,
    bool? isFeatured,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      parentId: parentId ?? this.parentId,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

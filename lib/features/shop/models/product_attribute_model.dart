class ProductAttributeModel {
  String? name;
  final List<String>? values;

  ProductAttributeModel({
    this.name,
    this.values,
  });

  /// Convert model to JSON structure so that you can store data in Firestore
  toJson() {
    return {
      'Name': name,
      'Values': values,
    };
  }

  /// Map from firebase to user model
  factory ProductAttributeModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) {
      return ProductAttributeModel();
    }
    return ProductAttributeModel(
      name: data.containsKey('Name') ? data['Name'] : '',
      values: List<String>.from(
        data['Values'],
      ),
    );
  }
}

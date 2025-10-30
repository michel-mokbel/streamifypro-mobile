class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? nameAr;

  const CategoryModel({required this.id, required this.name, this.icon, this.nameAr});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? 'Unnamed').toString(),
      icon: json['Icon']?.toString() ?? json['icon']?.toString(),
      nameAr: (json['NameAr'] ?? json['name_ar'] ?? json['CategoryNameAr'] ?? json['categoryNameAr'])?.toString(),
    );
  }
}



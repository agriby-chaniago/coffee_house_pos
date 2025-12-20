class AddOn {
  final String? id;
  final String name;
  final String category; // Topping, Sweetener, Milk, Syrup, Coffee
  final double additionalPrice;
  final bool isDefault;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddOn({
    this.id,
    required this.name,
    required this.category,
    required this.additionalPrice,
    this.isDefault = false,
    required this.sortOrder,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['\$id'] as String?,
      name: json['name'] as String,
      category: json['category'] as String,
      additionalPrice: (json['additionalPrice'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'] as String)
          : null,
      updatedAt: json['\$updatedAt'] != null
          ? DateTime.parse(json['\$updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'category': category,
      'additionalPrice': additionalPrice,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };

    // Include id if available
    if (id != null) {
      json['\$id'] = id!;
    }

    return json;
  }

  AddOn copyWith({
    String? id,
    String? name,
    String? category,
    double? additionalPrice,
    bool? isDefault,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddOn(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      additionalPrice: additionalPrice ?? this.additionalPrice,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AddOn(id: $id, name: $name, category: $category, price: $additionalPrice)';
  }
}

// Add-on categories constants
class AddOnCategory {
  static const String topping = 'Topping';
  static const String sweetener = 'Sweetener';
  static const String milk = 'Milk';
  static const String syrup = 'Syrup';
  static const String coffee = 'Coffee'; // for Extra Shot

  static const List<String> all = [
    topping,
    sweetener,
    milk,
    syrup,
    coffee,
  ];
}

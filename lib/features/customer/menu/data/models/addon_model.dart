import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/constants/app_constants.dart';

part 'addon_model.freezed.dart';

@freezed
class AddOn with _$AddOn {
  const AddOn._();

  const factory AddOn({
    String? id, // Appwrite $id
    required String name,
    required String category,
    required double additionalPrice,
    @Default(false) bool isDefault,
    required int sortOrder,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AddOn;

  factory AddOn.fromJson(Map<String, dynamic> json) {
    // Handle Appwrite $id field
    String? id;
    if (json.containsKey('\$id')) {
      id = json['\$id'];
    }

    // Handle Appwrite timestamp fields ($createdAt, $updatedAt)
    DateTime createdAt;
    if (json.containsKey('\$createdAt')) {
      createdAt = DateTime.parse(json['\$createdAt']);
    } else if (json.containsKey('createdAt')) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    if (json.containsKey('\$updatedAt')) {
      updatedAt = DateTime.parse(json['\$updatedAt']);
    } else if (json.containsKey('updatedAt')) {
      updatedAt = DateTime.parse(json['updatedAt']);
    } else {
      updatedAt = DateTime.now();
    }

    return AddOn(
      id: id,
      name: json['name'],
      category: json['category'],
      additionalPrice: (json['additionalPrice'] as num).toDouble(),
      isDefault: json['isDefault'] ?? false,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'additionalPrice': additionalPrice,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

extension AddOnExtension on AddOn {
  AddOnCategory get categoryEnum {
    switch (category.toLowerCase()) {
      case 'milktype':
      case 'milk type':
        return AddOnCategory.milkType;
      case 'sugarlevel':
      case 'sugar level':
        return AddOnCategory.sugarLevel;
      case 'extras':
        return AddOnCategory.extras;
      case 'icelevel':
      case 'ice level':
        return AddOnCategory.iceLevel;
      default:
        return AddOnCategory.extras;
    }
  }
}

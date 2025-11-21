import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_variant_model.dart';

part 'product_model.freezed.dart';

@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    String? id, // Appwrite $id
    required String name,
    required String description,
    required String category,
    required String imageUrl,
    required List<ProductVariant> variants,
    required List<String> availableAddOnIds,
    required String stockUnit, // 'pcs', 'kg', 'liter', 'gram', 'ml'
    required double currentStock,
    required double minStock,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle Appwrite $id field
    String? id;
    if (json.containsKey('\$id')) {
      id = json['\$id'];
    }

    // Handle variants parsing from JSON string if needed
    List<ProductVariant> variants;
    if (json['variants'] is String) {
      variants = (jsonDecode(json['variants']) as List)
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList();
    } else {
      variants = (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    // Handle availableAddOnIds parsing from JSON string if needed
    List<String> availableAddOnIds;
    if (json['availableAddOnIds'] is String) {
      availableAddOnIds =
          List<String>.from(jsonDecode(json['availableAddOnIds']));
    } else {
      availableAddOnIds = List<String>.from(json['availableAddOnIds']);
    }

    return Product(
      id: id,
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      variants: variants,
      availableAddOnIds: availableAddOnIds,
      stockUnit: json['stockUnit'],
      currentStock: (json['currentStock'] as num).toDouble(),
      minStock: (json['minStock'] as num).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['\$createdAt'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['\$updatedAt'] ?? json['updatedAt']),
    );
  }

  // Custom toJson for AppWrite
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'variants': jsonEncode(variants.map((v) => v.toJson()).toList()),
      'availableAddOnIds': jsonEncode(availableAddOnIds),
      'stockUnit': stockUnit,
      'currentStock': currentStock,
      'minStock': minStock,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toAppwriteJson() {
    final json = toJson();
    if (id != null) {
      json['\$id'] = id;
    }
    return json;
  }
}

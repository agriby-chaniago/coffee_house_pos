import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_constants.dart';

part 'user_model.freezed.dart';

@freezed
class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    String? id,
    required String name,
    required String email,
    required String role, // Store as string for AppWrite
    @Default(false) bool emailVerified,
    String? phone,
    required DateTime createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Handle Appwrite $id field
    String? id;
    if (json.containsKey('\$id')) {
      id = json['\$id'];
    }

    return AppUser(
      id: id,
      name: json['name'],
      email: json['email'],
      role: json['role'],
      emailVerified: json['emailVerified'] ?? false,
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

extension AppUserExtension on AppUser {
  UserRole get roleEnum {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'customer':
        return UserRole.customer;
      default:
        return UserRole.customer;
    }
  }

  bool get isAdmin => roleEnum == UserRole.admin;
  bool get isCustomer => roleEnum == UserRole.customer;
}

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.role,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['UserID'] ?? "").toString(),
      fullName: json['full_name'] ?? json['Fullname'] ?? "User",
      role: (json['role_id'] ?? json['role'] ?? "1").toString(),
      email: json['email'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      'email': email,
    };
  }
}

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['UserID'] ?? "").toString(),
      username: json['username'] ?? "",
      fullName: json['full_name'] ?? json['Fullname'] ?? "User",
      role: (json['role_id'] ?? json['role'] ?? "1").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
    };
  }
}

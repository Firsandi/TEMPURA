import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String role;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  @override
  List<Object?> get props => [id, username, fullName, role];
}

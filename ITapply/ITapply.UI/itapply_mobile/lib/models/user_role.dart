import 'package:json_annotation/json_annotation.dart';

part 'user_role.g.dart';
@JsonSerializable()
class UserRole {
  final int id;
  final int userId;
  final String? userEmail;
  final int roleId;
  final String? roleName;

  UserRole({
    required this.id,
    required this.userId,
    this.userEmail,
    required this.roleId,
    this.roleName,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}
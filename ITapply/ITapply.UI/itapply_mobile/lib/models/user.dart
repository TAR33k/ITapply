import 'package:itapply_desktop/models/role.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';
@JsonSerializable(explicitToJson: true)
class User {
  final int id;
  final String email;
  final DateTime registrationDate;
  final bool isActive;
  final List<Role> roles;

  User({
    required this.id,
    required this.email,
    required this.registrationDate,
    required this.isActive,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
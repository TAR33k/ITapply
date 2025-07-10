import 'package:json_annotation/json_annotation.dart';

part 'user_role_insert_request.g.dart';

@JsonSerializable()
class UserRoleInsertRequest {
  final int userId;
  final int roleId;

  UserRoleInsertRequest({
    required this.userId,
    required this.roleId,
  });

  factory UserRoleInsertRequest.fromJson(Map<String, dynamic> json) => _$UserRoleInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleInsertRequestToJson(this);
}
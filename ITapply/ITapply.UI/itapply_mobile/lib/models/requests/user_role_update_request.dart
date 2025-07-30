import 'package:json_annotation/json_annotation.dart';

part 'user_role_update_request.g.dart';

@JsonSerializable()
class UserRoleUpdateRequest {
  final int userId;
  final int roleId;

  UserRoleUpdateRequest({
    required this.userId,
    required this.roleId,
  });

  factory UserRoleUpdateRequest.fromJson(Map<String, dynamic> json) => _$UserRoleUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleUpdateRequestToJson(this);
}

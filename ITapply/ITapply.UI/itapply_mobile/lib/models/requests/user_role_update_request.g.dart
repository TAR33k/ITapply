// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRoleUpdateRequest _$UserRoleUpdateRequestFromJson(
  Map<String, dynamic> json,
) => UserRoleUpdateRequest(
  userId: (json['userId'] as num).toInt(),
  roleId: (json['roleId'] as num).toInt(),
);

Map<String, dynamic> _$UserRoleUpdateRequestToJson(
  UserRoleUpdateRequest instance,
) => <String, dynamic>{'userId': instance.userId, 'roleId': instance.roleId};

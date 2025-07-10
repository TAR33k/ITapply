// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRoleInsertRequest _$UserRoleInsertRequestFromJson(
  Map<String, dynamic> json,
) => UserRoleInsertRequest(
  userId: (json['userId'] as num).toInt(),
  roleId: (json['roleId'] as num).toInt(),
);

Map<String, dynamic> _$UserRoleInsertRequestToJson(
  UserRoleInsertRequest instance,
) => <String, dynamic>{'userId': instance.userId, 'roleId': instance.roleId};

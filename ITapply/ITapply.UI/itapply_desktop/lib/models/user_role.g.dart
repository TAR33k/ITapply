// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  userEmail: json['userEmail'] as String?,
  roleId: (json['roleId'] as num).toInt(),
  roleName: json['roleName'] as String?,
);

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userEmail': instance.userEmail,
  'roleId': instance.roleId,
  'roleName': instance.roleName,
};

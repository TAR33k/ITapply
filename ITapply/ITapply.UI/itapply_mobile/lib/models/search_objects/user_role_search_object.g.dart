// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: unused_element
UserRoleSearchObject _$UserRoleSearchObjectFromJson(
  Map<String, dynamic> json,
) => UserRoleSearchObject(
  UserId: (json['UserId'] as num?)?.toInt(),
  RoleId: (json['RoleId'] as num?)?.toInt(),
  RoleName: json['RoleName'] as String?,
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$UserRoleSearchObjectToJson(
  UserRoleSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'UserId': instance.UserId,
  'RoleId': instance.RoleId,
  'RoleName': instance.RoleName,
};

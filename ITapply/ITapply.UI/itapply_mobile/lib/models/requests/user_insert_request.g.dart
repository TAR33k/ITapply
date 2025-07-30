// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInsertRequest _$UserInsertRequestFromJson(Map<String, dynamic> json) =>
    UserInsertRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      roleIds: (json['roleIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UserInsertRequestToJson(UserInsertRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'roleIds': instance.roleIds,
    };

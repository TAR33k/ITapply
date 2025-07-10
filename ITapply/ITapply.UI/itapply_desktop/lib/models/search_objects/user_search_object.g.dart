// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSearchObject _$UserSearchObjectFromJson(Map<String, dynamic> json) =>
    UserSearchObject(
      Email: json['Email'] as String?,
      RegistrationDate: json['RegistrationDate'] == null
          ? null
          : DateTime.parse(json['RegistrationDate'] as String),
      IsActive: json['IsActive'] as bool?,
      Page: (json['Page'] as num?)?.toInt() ?? 0,
      PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
      IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
      RetrieveAll: json['RetrieveAll'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSearchObjectToJson(UserSearchObject instance) =>
    <String, dynamic>{
      'Page': instance.Page,
      'PageSize': instance.PageSize,
      'IncludeTotalCount': instance.IncludeTotalCount,
      'RetrieveAll': instance.RetrieveAll,
      'Email': instance.Email,
      'RegistrationDate': instance.RegistrationDate?.toIso8601String(),
      'IsActive': instance.IsActive,
    };

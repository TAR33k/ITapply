// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkillSearchObject _$SkillSearchObjectFromJson(Map<String, dynamic> json) =>
    SkillSearchObject(
      Name: json['Name'] as String?,
      Page: (json['Page'] as num?)?.toInt() ?? 0,
      PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
      IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
      RetrieveAll: json['RetrieveAll'] as bool? ?? false,
    );

Map<String, dynamic> _$SkillSearchObjectToJson(SkillSearchObject instance) =>
    <String, dynamic>{
      'Page': instance.Page,
      'PageSize': instance.PageSize,
      'IncludeTotalCount': instance.IncludeTotalCount,
      'RetrieveAll': instance.RetrieveAll,
      'Name': instance.Name,
    };

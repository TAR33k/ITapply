// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_skill_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerSkillSearchObject _$EmployerSkillSearchObjectFromJson(
  Map<String, dynamic> json,
) => EmployerSkillSearchObject(
  EmployerId: (json['EmployerId'] as num?)?.toInt(),
  SkillId: (json['SkillId'] as num?)?.toInt(),
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$EmployerSkillSearchObjectToJson(
  EmployerSkillSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'EmployerId': instance.EmployerId,
  'SkillId': instance.SkillId,
};

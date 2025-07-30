// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_skill_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateSkillSearchObject _$CandidateSkillSearchObjectFromJson(
  Map<String, dynamic> json,
) => CandidateSkillSearchObject(
  CandidateId: (json['CandidateId'] as num?)?.toInt(),
  SkillId: (json['SkillId'] as num?)?.toInt(),
  MinLevel: (json['MinLevel'] as num?)?.toInt(),
  MaxLevel: (json['MaxLevel'] as num?)?.toInt(),
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$CandidateSkillSearchObjectToJson(
  CandidateSkillSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'CandidateId': instance.CandidateId,
  'SkillId': instance.SkillId,
  'MinLevel': instance.MinLevel,
  'MaxLevel': instance.MaxLevel,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting_skill_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobPostingSkillSearchObject _$JobPostingSkillSearchObjectFromJson(
  Map<String, dynamic> json,
) => JobPostingSkillSearchObject(
  JobPostingId: (json['JobPostingId'] as num?)?.toInt(),
  SkillId: (json['SkillId'] as num?)?.toInt(),
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$JobPostingSkillSearchObjectToJson(
  JobPostingSkillSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'JobPostingId': instance.JobPostingId,
  'SkillId': instance.SkillId,
};

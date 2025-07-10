// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting_search_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobPostingSearchObject _$JobPostingSearchObjectFromJson(
  Map<String, dynamic> json,
) => JobPostingSearchObject(
  Title: json['Title'] as String?,
  EmployerId: (json['EmployerId'] as num?)?.toInt(),
  EmployerName: json['EmployerName'] as String?,
  employmentType: $enumDecodeNullable(
    _$EmploymentTypeEnumMap,
    json['EmploymentType'],
  ),
  experienceLevel: $enumDecodeNullable(
    _$ExperienceLevelEnumMap,
    json['ExperienceLevel'],
  ),
  LocationId: (json['LocationId'] as num?)?.toInt(),
  remote: $enumDecodeNullable(_$RemoteEnumMap, json['Remote']),
  MinSalary: (json['MinSalary'] as num?)?.toInt(),
  MaxSalary: (json['MaxSalary'] as num?)?.toInt(),
  PostedAfter: json['PostedAfter'] == null
      ? null
      : DateTime.parse(json['PostedAfter'] as String),
  DeadlineBefore: json['DeadlineBefore'] == null
      ? null
      : DateTime.parse(json['DeadlineBefore'] as String),
  Status: $enumDecodeNullable(_$JobPostingStatusEnumMap, json['Status']),
  SkillIds: (json['SkillIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  IncludeExpired: json['IncludeExpired'] as bool?,
  Page: (json['Page'] as num?)?.toInt() ?? 0,
  PageSize: (json['PageSize'] as num?)?.toInt() ?? 10,
  IncludeTotalCount: json['IncludeTotalCount'] as bool? ?? false,
  RetrieveAll: json['RetrieveAll'] as bool? ?? false,
);

Map<String, dynamic> _$JobPostingSearchObjectToJson(
  JobPostingSearchObject instance,
) => <String, dynamic>{
  'Page': instance.Page,
  'PageSize': instance.PageSize,
  'IncludeTotalCount': instance.IncludeTotalCount,
  'RetrieveAll': instance.RetrieveAll,
  'Title': instance.Title,
  'EmployerId': instance.EmployerId,
  'EmployerName': instance.EmployerName,
  'EmploymentType': _employmentTypeToJson(instance.employmentType),
  'ExperienceLevel': _experienceLevelToJson(instance.experienceLevel),
  'LocationId': instance.LocationId,
  'Remote': _remoteToJson(instance.remote),
  'MinSalary': instance.MinSalary,
  'MaxSalary': instance.MaxSalary,
  'PostedAfter': instance.PostedAfter?.toIso8601String(),
  'DeadlineBefore': instance.DeadlineBefore?.toIso8601String(),
  'Status': _jobPostingStatusToJson(instance.Status),
  'SkillIds': instance.SkillIds,
  'IncludeExpired': instance.IncludeExpired,
};

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 'fullTime',
  EmploymentType.partTime: 'partTime',
  EmploymentType.contract: 'contract',
  EmploymentType.internship: 'internship',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.entryLevel: 'entryLevel',
  ExperienceLevel.junior: 'junior',
  ExperienceLevel.mid: 'mid',
  ExperienceLevel.senior: 'senior',
  ExperienceLevel.lead: 'lead',
};

const _$RemoteEnumMap = {
  Remote.yes: 'yes',
  Remote.no: 'no',
  Remote.hybrid: 'hybrid',
};

const _$JobPostingStatusEnumMap = {
  JobPostingStatus.active: 'active',
  JobPostingStatus.closed: 'closed',
};

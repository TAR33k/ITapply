// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobPostingInsertRequest _$JobPostingInsertRequestFromJson(
  Map<String, dynamic> json,
) => JobPostingInsertRequest(
  employerId: (json['employerId'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  requirements: json['requirements'] as String?,
  benefits: json['benefits'] as String?,
  employmentType: $enumDecode(_$EmploymentTypeEnumMap, json['employmentType']),
  experienceLevel: $enumDecode(
    _$ExperienceLevelEnumMap,
    json['experienceLevel'],
  ),
  locationId: (json['locationId'] as num?)?.toInt(),
  remote: $enumDecode(_$RemoteEnumMap, json['remote']),
  minSalary: (json['minSalary'] as num?)?.toInt(),
  maxSalary: (json['maxSalary'] as num?)?.toInt(),
  applicationDeadline: DateTime.parse(json['applicationDeadline'] as String),
  skillIds: (json['skillIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$JobPostingInsertRequestToJson(
  JobPostingInsertRequest instance,
) => <String, dynamic>{
  'employerId': instance.employerId,
  'title': instance.title,
  'description': instance.description,
  'requirements': instance.requirements,
  'benefits': instance.benefits,
  'employmentType': _employmentTypeToJson(instance.employmentType),
  'experienceLevel': _experienceLevelToJson(instance.experienceLevel),
  'locationId': instance.locationId,
  'remote': _remoteToJson(instance.remote),
  'minSalary': instance.minSalary,
  'maxSalary': instance.maxSalary,
  'applicationDeadline': instance.applicationDeadline.toIso8601String(),
  'skillIds': instance.skillIds,
};

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 0,
  EmploymentType.partTime: 1,
  EmploymentType.contract: 2,
  EmploymentType.internship: 3,
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.entryLevel: 0,
  ExperienceLevel.junior: 1,
  ExperienceLevel.mid: 2,
  ExperienceLevel.senior: 3,
  ExperienceLevel.lead: 4,
};

const _$RemoteEnumMap = {Remote.yes: 0, Remote.no: 1, Remote.hybrid: 2};

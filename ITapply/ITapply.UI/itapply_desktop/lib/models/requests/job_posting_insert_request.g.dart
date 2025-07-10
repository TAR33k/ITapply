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

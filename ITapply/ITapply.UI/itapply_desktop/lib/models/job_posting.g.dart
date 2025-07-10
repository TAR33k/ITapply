// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobPosting _$JobPostingFromJson(Map<String, dynamic> json) => JobPosting(
  id: (json['id'] as num).toInt(),
  employerId: (json['employerId'] as num).toInt(),
  employerName: json['employerName'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  requirements: json['requirements'] as String?,
  benefits: json['benefits'] as String?,
  employmentType: $enumDecode(
    _$EmploymentTypeEnumMap,
    json['employmentType'],
    unknownValue: EmploymentType.fullTime,
  ),
  experienceLevel: $enumDecode(
    _$ExperienceLevelEnumMap,
    json['experienceLevel'],
    unknownValue: ExperienceLevel.entryLevel,
  ),
  locationId: (json['locationId'] as num?)?.toInt(),
  locationName: json['locationName'] as String?,
  remote: $enumDecode(_$RemoteEnumMap, json['remote'], unknownValue: Remote.no),
  minSalary: (json['minSalary'] as num?)?.toInt(),
  maxSalary: (json['maxSalary'] as num?)?.toInt(),
  applicationDeadline: DateTime.parse(json['applicationDeadline'] as String),
  postedDate: DateTime.parse(json['postedDate'] as String),
  status: $enumDecode(
    _$JobPostingStatusEnumMap,
    json['status'],
    unknownValue: JobPostingStatus.active,
  ),
  skills: (json['skills'] as List<dynamic>)
      .map((e) => JobPostingSkill.fromJson(e as Map<String, dynamic>))
      .toList(),
  applicationCount: (json['applicationCount'] as num).toInt(),
);

Map<String, dynamic> _$JobPostingToJson(JobPosting instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employerId': instance.employerId,
      'employerName': instance.employerName,
      'title': instance.title,
      'description': instance.description,
      'requirements': instance.requirements,
      'benefits': instance.benefits,
      'employmentType': _$EmploymentTypeEnumMap[instance.employmentType]!,
      'experienceLevel': _$ExperienceLevelEnumMap[instance.experienceLevel]!,
      'locationId': instance.locationId,
      'locationName': instance.locationName,
      'remote': _$RemoteEnumMap[instance.remote]!,
      'minSalary': instance.minSalary,
      'maxSalary': instance.maxSalary,
      'applicationDeadline': instance.applicationDeadline.toIso8601String(),
      'postedDate': instance.postedDate.toIso8601String(),
      'status': _$JobPostingStatusEnumMap[instance.status]!,
      'skills': instance.skills.map((e) => e.toJson()).toList(),
      'applicationCount': instance.applicationCount,
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

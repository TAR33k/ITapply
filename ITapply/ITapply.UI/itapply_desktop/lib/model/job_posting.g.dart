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
  employmentType: (json['employmentType'] as num).toInt(),
  experienceLevel: (json['experienceLevel'] as num).toInt(),
  locationId: (json['locationId'] as num?)?.toInt(),
  locationName: json['locationName'] as String?,
  remote: (json['remote'] as num).toInt(),
  minSalary: (json['minSalary'] as num).toInt(),
  maxSalary: (json['maxSalary'] as num).toInt(),
  applicationDeadline: DateTime.parse(json['applicationDeadline'] as String),
  postedDate: DateTime.parse(json['postedDate'] as String),
  status: (json['status'] as num).toInt(),
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
      'employmentType': instance.employmentType,
      'experienceLevel': instance.experienceLevel,
      'locationId': instance.locationId,
      'locationName': instance.locationName,
      'remote': instance.remote,
      'minSalary': instance.minSalary,
      'maxSalary': instance.maxSalary,
      'applicationDeadline': instance.applicationDeadline.toIso8601String(),
      'postedDate': instance.postedDate.toIso8601String(),
      'status': instance.status,
      'skills': instance.skills,
      'applicationCount': instance.applicationCount,
    };

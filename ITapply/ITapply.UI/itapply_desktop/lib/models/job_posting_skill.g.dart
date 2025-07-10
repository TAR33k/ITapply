// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting_skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobPostingSkill _$JobPostingSkillFromJson(Map<String, dynamic> json) =>
    JobPostingSkill(
      id: (json['id'] as num).toInt(),
      jobPostingId: (json['jobPostingId'] as num).toInt(),
      jobPostingTitle: json['jobPostingTitle'] as String?,
      employerName: json['employerName'] as String?,
      skillId: (json['skillId'] as num).toInt(),
      skillName: json['skillName'] as String?,
    );

Map<String, dynamic> _$JobPostingSkillToJson(JobPostingSkill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobPostingId': instance.jobPostingId,
      'jobPostingTitle': instance.jobPostingTitle,
      'employerName': instance.employerName,
      'skillId': instance.skillId,
      'skillName': instance.skillName,
    };

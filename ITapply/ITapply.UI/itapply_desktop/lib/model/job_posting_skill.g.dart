// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting_skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobPostingSkill _$JobPostingSkillFromJson(Map<String, dynamic> json) =>
    JobPostingSkill(
      id: (json['id'] as num).toInt(),
      jobPostingId: (json['jobPostingId'] as num).toInt(),
      skillId: (json['skillId'] as num).toInt(),
    );

Map<String, dynamic> _$JobPostingSkillToJson(JobPostingSkill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobPostingId': instance.jobPostingId,
      'skillId': instance.skillId,
    };

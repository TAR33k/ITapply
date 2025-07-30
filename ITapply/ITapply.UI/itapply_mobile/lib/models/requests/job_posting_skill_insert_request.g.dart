// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_posting_skill_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobPostingSkillInsertRequest _$JobPostingSkillInsertRequestFromJson(
  Map<String, dynamic> json,
) => JobPostingSkillInsertRequest(
  jobPostingId: (json['jobPostingId'] as num).toInt(),
  skillId: (json['skillId'] as num).toInt(),
);

Map<String, dynamic> _$JobPostingSkillInsertRequestToJson(
  JobPostingSkillInsertRequest instance,
) => <String, dynamic>{
  'jobPostingId': instance.jobPostingId,
  'skillId': instance.skillId,
};

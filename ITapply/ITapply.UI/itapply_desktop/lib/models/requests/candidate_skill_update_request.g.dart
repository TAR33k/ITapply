// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_skill_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateSkillUpdateRequest _$CandidateSkillUpdateRequestFromJson(
  Map<String, dynamic> json,
) => CandidateSkillUpdateRequest(
  skillId: (json['skillId'] as num).toInt(),
  level: (json['level'] as num).toInt(),
);

Map<String, dynamic> _$CandidateSkillUpdateRequestToJson(
  CandidateSkillUpdateRequest instance,
) => <String, dynamic>{'skillId': instance.skillId, 'level': instance.level};

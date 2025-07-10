// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_skill_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateSkillInsertRequest _$CandidateSkillInsertRequestFromJson(
  Map<String, dynamic> json,
) => CandidateSkillInsertRequest(
  candidateId: (json['candidateId'] as num).toInt(),
  skillId: (json['skillId'] as num).toInt(),
  level: (json['level'] as num).toInt(),
);

Map<String, dynamic> _$CandidateSkillInsertRequestToJson(
  CandidateSkillInsertRequest instance,
) => <String, dynamic>{
  'candidateId': instance.candidateId,
  'skillId': instance.skillId,
  'level': instance.level,
};

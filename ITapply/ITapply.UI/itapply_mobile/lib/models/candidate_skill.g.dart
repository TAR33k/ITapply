// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateSkill _$CandidateSkillFromJson(Map<String, dynamic> json) =>
    CandidateSkill(
      id: (json['id'] as num).toInt(),
      candidateId: (json['candidateId'] as num).toInt(),
      candidateName: json['candidateName'] as String?,
      skillId: (json['skillId'] as num).toInt(),
      skillName: json['skillName'] as String?,
      level: (json['level'] as num).toInt(),
    );

Map<String, dynamic> _$CandidateSkillToJson(CandidateSkill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'candidateId': instance.candidateId,
      'candidateName': instance.candidateName,
      'skillId': instance.skillId,
      'skillName': instance.skillName,
      'level': instance.level,
    };

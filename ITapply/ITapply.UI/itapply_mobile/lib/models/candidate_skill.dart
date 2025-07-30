import 'package:json_annotation/json_annotation.dart';

part 'candidate_skill.g.dart';
@JsonSerializable()
class CandidateSkill {
  final int id;
  final int candidateId;
  final String? candidateName;
  final int skillId;
  final String? skillName;
  final int level;

  CandidateSkill({
    required this.id,
    required this.candidateId,
    this.candidateName,
    required this.skillId,
    this.skillName,
    required this.level,
  });

  factory CandidateSkill.fromJson(Map<String, dynamic> json) => _$CandidateSkillFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateSkillToJson(this);
}

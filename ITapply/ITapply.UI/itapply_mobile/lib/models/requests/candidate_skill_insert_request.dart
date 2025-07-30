import 'package:json_annotation/json_annotation.dart';

part 'candidate_skill_insert_request.g.dart';

@JsonSerializable()
class CandidateSkillInsertRequest {
  final int candidateId;
  final int skillId;
  final int level;

  CandidateSkillInsertRequest({
    required this.candidateId,
    required this.skillId,
    required this.level,
  });

  factory CandidateSkillInsertRequest.fromJson(Map<String, dynamic> json) => _$CandidateSkillInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateSkillInsertRequestToJson(this);
}

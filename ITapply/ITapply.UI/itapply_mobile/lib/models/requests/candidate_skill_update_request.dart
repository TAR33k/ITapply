import 'package:json_annotation/json_annotation.dart';

part 'candidate_skill_update_request.g.dart';

@JsonSerializable()
class CandidateSkillUpdateRequest {
  final int skillId;
  final int level;

  CandidateSkillUpdateRequest({
    required this.skillId,
    required this.level,
  });

  factory CandidateSkillUpdateRequest.fromJson(Map<String, dynamic> json) => _$CandidateSkillUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateSkillUpdateRequestToJson(this);
}

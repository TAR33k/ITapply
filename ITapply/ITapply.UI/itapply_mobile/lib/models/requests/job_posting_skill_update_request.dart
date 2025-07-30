import 'package:json_annotation/json_annotation.dart';

part 'job_posting_skill_update_request.g.dart';

@JsonSerializable()
class JobPostingSkillUpdateRequest {
  final int skillId;

  JobPostingSkillUpdateRequest({required this.skillId});

  factory JobPostingSkillUpdateRequest.fromJson(Map<String, dynamic> json) => _$JobPostingSkillUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingSkillUpdateRequestToJson(this);
}
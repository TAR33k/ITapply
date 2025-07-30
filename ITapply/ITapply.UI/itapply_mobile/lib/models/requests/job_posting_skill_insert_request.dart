import 'package:json_annotation/json_annotation.dart';

part 'job_posting_skill_insert_request.g.dart';

@JsonSerializable()
class JobPostingSkillInsertRequest {
  final int jobPostingId;
  final int skillId;

  JobPostingSkillInsertRequest({
    required this.jobPostingId,
    required this.skillId,
  });
  
  factory JobPostingSkillInsertRequest.fromJson(Map<String, dynamic> json) => _$JobPostingSkillInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingSkillInsertRequestToJson(this);
}

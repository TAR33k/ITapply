import 'package:json_annotation/json_annotation.dart';

part 'job_posting_skill.g.dart';
@JsonSerializable()
class JobPostingSkill {
  final int id;
  final int jobPostingId;
  final int skillId;

  JobPostingSkill({
    required this.id,
    required this.jobPostingId,
    required this.skillId,
  });

  factory JobPostingSkill.fromJson(Map<String, dynamic> json) => _$JobPostingSkillFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingSkillToJson(this);
}

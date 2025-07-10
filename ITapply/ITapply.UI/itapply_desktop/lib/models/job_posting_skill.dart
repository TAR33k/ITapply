import 'package:json_annotation/json_annotation.dart';

part 'job_posting_skill.g.dart';
@JsonSerializable()
class JobPostingSkill {
  final int id;
  final int jobPostingId;
  final String? jobPostingTitle;
  final String? employerName;
  final int skillId;
  final String? skillName;

  JobPostingSkill({
    required this.id,
    required this.jobPostingId,
    this.jobPostingTitle,
    this.employerName,
    required this.skillId,
    this.skillName,
  });

  factory JobPostingSkill.fromJson(Map<String, dynamic> json) => _$JobPostingSkillFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingSkillToJson(this);
}
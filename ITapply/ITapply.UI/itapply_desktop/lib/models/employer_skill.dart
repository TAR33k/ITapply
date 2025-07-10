import 'package:json_annotation/json_annotation.dart';

part 'employer_skill.g.dart';
@JsonSerializable()
class EmployerSkill {
  final int id;
  final int employerId;
  final String? employerName;
  final int skillId;
  final String? skillName;

  EmployerSkill({
    required this.id,
    required this.employerId,
    this.employerName,
    required this.skillId,
    this.skillName,
  });

  factory EmployerSkill.fromJson(Map<String, dynamic> json) => _$EmployerSkillFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerSkillToJson(this);
}
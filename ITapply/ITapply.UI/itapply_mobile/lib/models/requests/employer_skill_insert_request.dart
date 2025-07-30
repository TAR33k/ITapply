import 'package:json_annotation/json_annotation.dart';

part 'employer_skill_insert_request.g.dart';

@JsonSerializable()
class EmployerSkillInsertRequest {
  final int employerId;
  final int skillId;

  EmployerSkillInsertRequest({
    required this.employerId,
    required this.skillId,
  });

  factory EmployerSkillInsertRequest.fromJson(Map<String, dynamic> json) => _$EmployerSkillInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerSkillInsertRequestToJson(this);
}
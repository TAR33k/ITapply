import 'package:json_annotation/json_annotation.dart';

part 'employer_skill_update_request.g.dart';

@JsonSerializable()
class EmployerSkillUpdateRequest {
  final int skillId;

  EmployerSkillUpdateRequest({
    required this.skillId,
  });

  factory EmployerSkillUpdateRequest.fromJson(Map<String, dynamic> json) => _$EmployerSkillUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerSkillUpdateRequestToJson(this);
}
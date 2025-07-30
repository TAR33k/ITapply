import 'package:json_annotation/json_annotation.dart';

part 'skill_update_request.g.dart';

@JsonSerializable()
class SkillUpdateRequest {
  final String name;

  SkillUpdateRequest({required this.name});

  factory SkillUpdateRequest.fromJson(Map<String, dynamic> json) => _$SkillUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SkillUpdateRequestToJson(this);
}
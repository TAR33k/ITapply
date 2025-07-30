import 'package:json_annotation/json_annotation.dart';

part 'skill_insert_request.g.dart';

@JsonSerializable()
class SkillInsertRequest {
  final String name;

  SkillInsertRequest({required this.name});

  factory SkillInsertRequest.fromJson(Map<String, dynamic> json) => _$SkillInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SkillInsertRequestToJson(this);
}

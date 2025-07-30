import 'package:json_annotation/json_annotation.dart';

part 'work_experience_update_request.g.dart';

@JsonSerializable()
class WorkExperienceUpdateRequest {
  final String? companyName;
  final String? position;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;

  WorkExperienceUpdateRequest({
    this.companyName,
    this.position,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory WorkExperienceUpdateRequest.fromJson(Map<String, dynamic> json) => _$WorkExperienceUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WorkExperienceUpdateRequestToJson(this);
}

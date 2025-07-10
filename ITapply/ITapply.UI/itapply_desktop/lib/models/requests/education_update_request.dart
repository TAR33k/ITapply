import 'package:json_annotation/json_annotation.dart';

part 'education_update_request.g.dart';

@JsonSerializable()
class EducationUpdateRequest {
  final String? institution;
  final String? degree;
  final String? fieldOfStudy;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;

  EducationUpdateRequest({
    this.institution,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory EducationUpdateRequest.fromJson(Map<String, dynamic> json) => _$EducationUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EducationUpdateRequestToJson(this);
}
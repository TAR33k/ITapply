import 'package:json_annotation/json_annotation.dart';

part 'education_insert_request.g.dart';

@JsonSerializable()
class EducationInsertRequest {
  final int candidateId;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  EducationInsertRequest({
    required this.candidateId,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.description,
  });

  factory EducationInsertRequest.fromJson(Map<String, dynamic> json) => _$EducationInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EducationInsertRequestToJson(this);
}

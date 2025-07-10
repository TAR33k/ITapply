import 'package:json_annotation/json_annotation.dart';

part 'work_experience_insert_request.g.dart';

@JsonSerializable()
class WorkExperienceInsertRequest {
  final int candidateId;
  final String companyName;
  final String position;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  WorkExperienceInsertRequest({
    required this.candidateId,
    required this.companyName,
    required this.position,
    required this.startDate,
    this.endDate,
    this.description,
  });
  
  factory WorkExperienceInsertRequest.fromJson(Map<String, dynamic> json) => _$WorkExperienceInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WorkExperienceInsertRequestToJson(this);
}
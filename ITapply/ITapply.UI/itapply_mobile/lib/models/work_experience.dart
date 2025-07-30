import 'package:json_annotation/json_annotation.dart';

part 'work_experience.g.dart';
@JsonSerializable()
class WorkExperience {
  final int id;
  final int candidateId;
  final String? candidateName;
  final String companyName;
  final String position;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final bool isCurrent;
  final String? duration;

  WorkExperience({
    required this.id,
    required this.candidateId,
    this.candidateName,
    required this.companyName,
    required this.position,
    required this.startDate,
    this.endDate,
    this.description,
    required this.isCurrent,
    this.duration,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) => _$WorkExperienceFromJson(json);
  Map<String, dynamic> toJson() => _$WorkExperienceToJson(this);
}

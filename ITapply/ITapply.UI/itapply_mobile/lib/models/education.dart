import 'package:json_annotation/json_annotation.dart';

part 'education.g.dart';
@JsonSerializable()
class Education {
  final int id;
  final int candidateId;
  final String? candidateName;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final bool isCurrent;
  final String? duration;

  Education({
    required this.id,
    required this.candidateId,
    this.candidateName,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.description,
    required this.isCurrent,
    this.duration,
  });

  factory Education.fromJson(Map<String, dynamic> json) => _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}
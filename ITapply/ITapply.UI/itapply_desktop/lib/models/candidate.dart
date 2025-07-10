import 'package:itapply_desktop/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidate.g.dart';
@JsonSerializable(explicitToJson: true)
class Candidate {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? title;
  final String? bio;
  final int? locationId;
  final String? locationName;
  final int experienceYears;
  @JsonKey(unknownEnumValue: ExperienceLevel.entryLevel)
  final ExperienceLevel experienceLevel;
  final DateTime registrationDate;
  final bool isActive;

  Candidate({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.title,
    this.bio,
    this.locationId,
    this.locationName,
    required this.experienceYears,
    required this.experienceLevel,
    required this.registrationDate,
    required this.isActive,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => _$CandidateFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateToJson(this);
}
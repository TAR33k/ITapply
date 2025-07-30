import 'package:itapply_desktop/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidate_insert_request.g.dart';

@JsonSerializable()
class CandidateInsertRequest {
  final int userId;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? title;
  final String? bio;
  final int? locationId;
  final int? experienceYears;
  @JsonKey(toJson: _experienceLevelToJson)
  final ExperienceLevel? experienceLevel;

  CandidateInsertRequest({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.title,
    this.bio,
    this.locationId,
    this.experienceYears,
    this.experienceLevel,
  });

  factory CandidateInsertRequest.fromJson(Map<String, dynamic> json) => _$CandidateInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateInsertRequestToJson(this);
}

int? _experienceLevelToJson(ExperienceLevel? level) => level?.index;
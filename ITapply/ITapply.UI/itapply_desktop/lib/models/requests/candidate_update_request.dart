import 'package:itapply_desktop/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidate_update_request.g.dart';

@JsonSerializable()
class CandidateUpdateRequest {
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? title;
  final String? bio;
  final int? locationId;
  final int? experienceYears;
  @JsonKey(toJson: _experienceLevelToJson)
  final ExperienceLevel? experienceLevel;

  CandidateUpdateRequest({
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.title,
    this.bio,
    this.locationId,
    this.experienceYears,
    this.experienceLevel,
  });

  factory CandidateUpdateRequest.fromJson(Map<String, dynamic> json) => _$CandidateUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateUpdateRequestToJson(this);
}

int? _experienceLevelToJson(ExperienceLevel? level) => level?.index;
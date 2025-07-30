import 'package:itapply_mobile/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_posting_insert_request.g.dart';

@JsonSerializable()
class JobPostingInsertRequest {
  final int employerId;
  final String title;
  final String description;
  final String? requirements;
  final String? benefits;
  @JsonKey(toJson: _employmentTypeToJson)
  final EmploymentType employmentType;
  @JsonKey(toJson: _experienceLevelToJson)
  final ExperienceLevel experienceLevel;
  final int? locationId;
  @JsonKey(toJson: _remoteToJson)
  final Remote remote;
  final int? minSalary;
  final int? maxSalary;
  final DateTime applicationDeadline;
  final List<int>? skillIds;

  JobPostingInsertRequest({
    required this.employerId,
    required this.title,
    required this.description,
    this.requirements,
    this.benefits,
    required this.employmentType,
    required this.experienceLevel,
    this.locationId,
    required this.remote,
    this.minSalary,
    this.maxSalary,
    required this.applicationDeadline,
    this.skillIds,
  });

  factory JobPostingInsertRequest.fromJson(Map<String, dynamic> json) => _$JobPostingInsertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingInsertRequestToJson(this);
}

int _employmentTypeToJson(EmploymentType type) => type.index;
int _experienceLevelToJson(ExperienceLevel level) => level.index;
int _remoteToJson(Remote remote) => remote.index;

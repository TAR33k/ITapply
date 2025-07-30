import 'package:itapply_mobile/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_posting_update_request.g.dart';

@JsonSerializable()
class JobPostingUpdateRequest {
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
  @JsonKey(toJson: _jobPostingStatusToJson)
  final JobPostingStatus status;
  final List<int>? skillIds;

  JobPostingUpdateRequest({
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
    required this.status,
    this.skillIds,
  });
  
  factory JobPostingUpdateRequest.fromJson(Map<String, dynamic> json) => _$JobPostingUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingUpdateRequestToJson(this);
}

int _employmentTypeToJson(EmploymentType type) => type.index;
int _experienceLevelToJson(ExperienceLevel level) => level.index;
int _remoteToJson(Remote remote) => remote.index;
int _jobPostingStatusToJson(JobPostingStatus status) => status.index;

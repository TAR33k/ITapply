import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/job_posting_skill.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_posting.g.dart';
@JsonSerializable(explicitToJson: true)
class JobPosting {
  final int id;
  final int employerId;
  final String employerName;
  final String title;
  final String description;
  final String? requirements;
  final String? benefits;
  @JsonKey(unknownEnumValue: EmploymentType.fullTime)
  final EmploymentType employmentType;
  @JsonKey(unknownEnumValue: ExperienceLevel.entryLevel)
  final ExperienceLevel experienceLevel;
  final int? locationId;
  final String? locationName;
  @JsonKey(unknownEnumValue: Remote.no)
  final Remote remote;
  final int? minSalary;
  final int? maxSalary;
  final DateTime applicationDeadline;
  final DateTime postedDate;
  @JsonKey(unknownEnumValue: JobPostingStatus.active)
  final JobPostingStatus status;
  final List<JobPostingSkill> skills;
  final int applicationCount;

  JobPosting({
    required this.id,
    required this.employerId,
    required this.employerName,
    required this.title,
    required this.description,
    this.requirements,
    this.benefits,
    required this.employmentType,
    required this.experienceLevel,
    this.locationId,
    this.locationName,
    required this.remote,
    this.minSalary,
    this.maxSalary,
    required this.applicationDeadline,
    required this.postedDate,
    required this.status,
    required this.skills,
    required this.applicationCount,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) => _$JobPostingFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostingToJson(this);
}

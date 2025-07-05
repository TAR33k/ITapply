import 'package:itapply_desktop/model/job_posting_skill.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_posting.g.dart';
@JsonSerializable()
class JobPosting {
  final int id;
  final int employerId;
  final String employerName;
  final String title; // max 200 chars
  final String description; // max 10000 chars
  final String? requirements; // max 5000 chars, optional
  final String? benefits; // max 3000 chars, optional
  final int employmentType; // enum
  final int experienceLevel; // enum
  final int? locationId;
  final String? locationName;
  final int remote; // enum
  final int minSalary;
  final int maxSalary;
  final DateTime applicationDeadline;
  final DateTime postedDate;
  final int status; // enum
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
    required this.minSalary,
    required this.maxSalary,
    required this.applicationDeadline,
    required this.postedDate,
    required this.status,
    required this.skills,
    required this.applicationCount,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) => _$JobPostingFromJson(json);
}
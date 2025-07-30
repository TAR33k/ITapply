import 'package:json_annotation/json_annotation.dart';

enum ExperienceLevel {
  @JsonValue(0)
  entryLevel,
  @JsonValue(1)
  junior,
  @JsonValue(2)
  mid,
  @JsonValue(3)
  senior,
  @JsonValue(4)
  lead,
}

enum EmploymentType {
  @JsonValue(0)
  fullTime,
  @JsonValue(1)
  partTime,
  @JsonValue(2)
  contract,
  @JsonValue(3)
  internship,
}

enum ApplicationStatus {
  @JsonValue(0)
  applied,
  @JsonValue(1)
  inConsideration,
  @JsonValue(2)
  interviewScheduled,
  @JsonValue(3)
  accepted,
  @JsonValue(4)
  rejected,
}

enum ReviewRelationship {
  @JsonValue(0)
  currentEmployee,
  @JsonValue(1)
  formerEmployee,
  @JsonValue(2)
  interviewee,
}

enum VerificationStatus {
  @JsonValue(0)
  pending,
  @JsonValue(1)
  approved,
  @JsonValue(2)
  rejected,
}

enum JobPostingStatus {
  @JsonValue(0)
  active,
  @JsonValue(1)
  closed,
}

enum ModerationStatus {
  @JsonValue(0)
  pending,
  @JsonValue(1)
  approved,
  @JsonValue(2)
  rejected,
}

enum Remote {
  @JsonValue(0)
  yes,
  @JsonValue(1)
  no,
  @JsonValue(2)
  hybrid,
}
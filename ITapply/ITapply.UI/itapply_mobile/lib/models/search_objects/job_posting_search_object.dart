import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_posting_search_object.g.dart';

@JsonSerializable()
class JobPostingSearchObject extends BaseSearchObject {
  String? Title;
  int? EmployerId;
  String? EmployerName;
  @JsonKey(name: 'EmploymentType', toJson: _employmentTypeToJson)
  EmploymentType? employmentType;
  @JsonKey(name: 'ExperienceLevel', toJson: _experienceLevelToJson)
  ExperienceLevel? experienceLevel;
  int? LocationId;
  @JsonKey(name: 'Remote', toJson: _remoteToJson)
  Remote? remote;
  int? MinSalary;
  int? MaxSalary;
  DateTime? PostedAfter;
  DateTime? DeadlineBefore;
  @JsonKey(toJson: _jobPostingStatusToJson)
  JobPostingStatus? Status;
  List<int>? SkillIds;
  bool? IncludeExpired;

  JobPostingSearchObject({
    this.Title,
    this.EmployerId,
    this.EmployerName,
    this.employmentType,
    this.experienceLevel,
    this.LocationId,
    this.remote,
    this.MinSalary,
    this.MaxSalary,
    this.PostedAfter,
    this.DeadlineBefore,
    this.Status,
    this.SkillIds,
    this.IncludeExpired,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$JobPostingSearchObjectToJson(this);
}

int? _employmentTypeToJson(EmploymentType? type) => type?.index;
int? _experienceLevelToJson(ExperienceLevel? level) => level?.index;
int? _remoteToJson(Remote? remote) => remote?.index;
int? _jobPostingStatusToJson(JobPostingStatus? status) => status?.index;

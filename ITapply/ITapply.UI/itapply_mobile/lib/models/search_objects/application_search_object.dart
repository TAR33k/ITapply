import 'package:itapply_mobile/models/enums.dart';
import 'package:itapply_mobile/models/search_objects/base_search_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application_search_object.g.dart';

@JsonSerializable()
class ApplicationSearchObject extends BaseSearchObject {
  int? CandidateId;
  int? JobPostingId;
  int? EmployerId;
  String? JobTitle;
  String? CandidateName;
  String? CompanyName;
  @JsonKey(toJson: _applicationStatusToJson)
  ApplicationStatus? Status;
  DateTime? ApplicationDateFrom;
  DateTime? ApplicationDateTo;

  ApplicationSearchObject({
    this.CandidateId,
    this.JobPostingId,
    this.EmployerId,
    this.JobTitle,
    this.CandidateName,
    this.CompanyName,
    this.Status,
    this.ApplicationDateFrom,
    this.ApplicationDateTo,
    super.Page,
    super.PageSize,
    super.IncludeTotalCount,
    super.RetrieveAll,
  });

  @override
  Map<String, dynamic> toJson() => _$ApplicationSearchObjectToJson(this);
}

int? _applicationStatusToJson(ApplicationStatus? status) => status?.index;
